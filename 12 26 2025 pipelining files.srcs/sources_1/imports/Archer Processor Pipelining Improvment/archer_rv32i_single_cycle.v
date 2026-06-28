//
// SPDX-License-Identifier: CERN-OHL-P-2.0+
//
// Copyright (C) 2021-2024 Embedded and Reconfigurable Computing Lab, American University of Beirut
// Contributed by:
// Mazen A. R. Saghir <mazen@aub.edu.lb>
//
// This source is distributed WITHOUT ANY EXPRESS OR IMPLIED WARRANTY,
// INCLUDING OF MERCHANTABILITY, SATISFACTORY QUALITY AND FITNESS FOR
// A PARTICULAR PURPOSE. Please see the CERN-OHL-P v2 for applicable
// conditions.
// Source location: https://github.com/ERCL-AUB/archer/rv32i_single_cycle
//
// Archer RV32I single-cycle datapath wrapper (top-level entity)

`include "archerdefs.v"

module archer_rv32i_single_cycle (
	input clk,
	input rst_n,
	// local instruction memory bus interface
	output [`ADDRLEN-1:0] imem_addr,
	output [`XLEN-1:0] imem_datain,
	input [`XLEN-1:0] imem_dataout,
	output imem_wen,
	output [3:0] imem_ben,
	// local data memory bus interface
	output [`ADDRLEN-1:0] dmem_addr,
	output [`XLEN-1:0] dmem_datain,
	input [`XLEN-1:0] dmem_dataout,
	output dmem_wen,
	output [`XLEN-1:0] PCsrctest,//added for test output
	output [3:0] dmem_ben
	);
    // pc wires
    wire [`XLEN-1:0] d_pc_in;
    wire [`XLEN-1:0] d_pc_out;

    // imem wires
    //wire [`ADDRLEN-1:0] d_imem_addr;
    wire [`XLEN-1:0] d_instr_word;

    // add4 wires
    wire [`XLEN-1:0] d_pcplus4;

    // control wires
    wire c_branch_out;
    wire c_jump;
    wire c_lui;
    wire c_PCSrc;
    wire c_reg_write;
    wire c_alu_src1;
    wire c_alu_src2;
    wire [3:0] c_alu_op;
    wire c_mem_write;
    wire c_mem_read;
    wire c_mem_to_reg;

    // register file wires

    wire [`XLEN-1:0] d_reg_file_datain;
    wire [`XLEN-1:0] d_regA;
    wire [`XLEN-1:0] d_regB;

    // immgen wires

    wire [`XLEN-1:0] d_immediate;

    // lui_mux wires

    wire [`XLEN-1:0] d_zero;
    wire [`XLEN-1:0] d_lui_mux_out;

    // alu_src1_mux wires 

    wire [`XLEN-1:0] d_alu_src1;

    // alu_src2_mux wires 

    wire [`XLEN-1:0] d_alu_src2;

    // alu wires

    wire [`XLEN-1:0] d_alu_out;

    // mem_mux wires

    wire [`XLEN-1:0] d_mem_mux_out;

    // lmb wires

    wire [1:0] d_byte_mask;
    wire d_sign_ext_n;
    wire [`XLEN-1:0] d_data_mem_out;

    // instruction word fields

    wire [`LOG2_XRF_SIZE-1:0] d_rs1;
    wire [`LOG2_XRF_SIZE-1:0] d_rs2;
    wire [`LOG2_XRF_SIZE-1:0] d_rd;
    wire [2:0] d_funct3;
    wire [6:0] d_funct7;
    
    // added mux wires
    wire [`XLEN-1:0] Stage_output;
    wire [`XLEN-1:0] alu_input1;
    wire [`XLEN-1:0] alu_input2;
    wire flush_sel;
    wire [10:0] input_control_wires;  
    wire [10:0] output_control_wires;  
    wire [`XLEN-1:0] branchcmp_inp_A;
    wire [`XLEN-1:0] branchcmp_inp_B;
    
    //added wires
    wire [`XLEN-1:0] targetPC;    
    //wire Stage_sel;
    wire R1_sel;
    wire R2_sel;
    
    // for hdu
    wire PCwrite;
    wire IF_ID_write;
 
    
    
    // for IF/ID datapath register
   
    wire [`XLEN-1:0] IF_ID_pc_out;
    wire [`XLEN-1:0] IF_ID_d_instr_word_out;
    wire [`XLEN-1:0] IF_ID_pc_plus4_out;
    
    // for ID/EX datapath register
    
    wire [`LOG2_XRF_SIZE-1:0] ID_EX_RS1; 
    wire [`LOG2_XRF_SIZE-1:0] ID_EX_RS2;
    wire [`LOG2_XRF_SIZE-1:0] ID_EX_RD;
    wire [`XLEN-1:0] ID_EX_regA;
    wire [`XLEN-1:0] ID_EX_regB;
    wire [`XLEN-1:0] ID_EX_immgen_result_out;
    wire [`XLEN-1:0] ID_EX_pc_plus_4_out;
    wire [2:0] ID_EX_funct3_out;
    wire [`XLEN-1:0] ID_EX_lui_result_out;
    
    wire [2:0] ID_EX_WBcntrl_out;
    wire [1:0] ID_EX_MEMcntrl_out;
    wire [5:0] ID_EX_EXcntrl_out;
    
    // for EX/MEM datapath register
    
    wire [`LOG2_XRF_SIZE-1:0] EX_MEM_RD;
    wire [`XLEN-1:0] EX_MEM_regB;
    wire [`XLEN-1:0] EX_MEM_pc_plus_4_out;
    wire [2:0] EX_MEM_funct3_out;
    wire [`XLEN-1:0] EX_MEM_alu_out;
    
    wire [2:0] EX_MEM_WBcntrl_out;
    wire [1:0] EX_MEM_MEMcntrl_out;
    
    // for MEM/WB datapath register
    
    wire [`LOG2_XRF_SIZE-1:0] MEM_WB_RD;
    wire [`XLEN-1:0] MEM_WB_pc_plus_4_out;
    wire [2:0] MEM_WB_funct3_out;
    wire [`XLEN-1:0] MEM_WB_alu_out;
    wire [`XLEN-1:0] MEM_WB_data_out;
    
    wire [2:0] MEM_WB_WBcntrl_out;
    //control wires added for debugging
    wire [2:0] WB_control_wires_in;
    wire [1:0] MEM_control_wires_in;
    wire [5:0] EX_control_wires_in;
    wire [2:0] WB_control_wires_out;
    wire [1:0] MEM_control_wires_out;
    wire [5:0] EX_control_wires_out;
    
    wire R1_branchcmp;
    wire R2_branchcmp;
    
    
    wire flush_signal;
    wire flush_current;
    wire [`XLEN-1:0] early_branch_output;
    wire early_branch_selector;
    wire Hit_memwb;
    wire Hit_exmem;
    
    //added bundled control wires (ID stage)
    assign EX_control_wires_in = {c_alu_op, c_alu_src2, c_alu_src1};
    assign MEM_control_wires_in = {c_mem_read,c_mem_write};
    assign WB_control_wires_in = {c_jump,c_reg_write,c_mem_to_reg};
   
    assign EX_control_wires_out = output_control_wires[10:5];
    assign MEM_control_wires_out = output_control_wires[4:3];
    assign WB_control_wires_out = output_control_wires[2:0];
   
    //added code
    assign input_control_wires = {EX_control_wires_in, MEM_control_wires_in, WB_control_wires_in};
    
    wire [`XLEN-1:0] mem_stage_mux;
   
    pc pc_inst (.clk(clk), 
                .rst_n(rst_n),
                .PCWrite(PCwrite), 
                .datain(d_pc_in), 
                .dataout(d_pc_out));
    
    lmb limb_inst (.proc_addr(d_pc_out), 
                   .proc_data_send(`XLEN'd0), 
                   .proc_data_receive(d_instr_word),
    		   .proc_byte_mask(2'b10), 
    		   .proc_sign_ext_n(1'b1), 
    		   .proc_mem_write(1'b0),
    		   .proc_mem_read(1'b1), 
    		   .mem_addr(imem_addr), 
    		   .mem_datain(imem_datain), 
    		   .mem_dataout(imem_dataout), 
    		   .mem_wen(imem_wen), 
    		   .mem_ben(imem_ben));
    		   
    add4 add4_inst (.datain(d_pc_out), // IF_ID_pc_out
    		    .result(d_pcplus4));
    
    mux2to1 pc_mux (.sel(c_PCSrc),//& !flush_sel
                    .input0(d_pcplus4), 
                    .input1(targetPC),
                    .muxout(d_pc_in));
    
    control control_inst (.instruction(IF_ID_d_instr_word_out), 
    			  .BranchCond(c_branch_out),
    			  .flush(flush_signal|| flush_current), 
    			  .Jump(c_jump), 
    			  .Lui(c_lui),
    			  .PCSrc(c_PCSrc),
    			  .RegWrite(c_reg_write),
    			  .ALUSrc1(c_alu_src1),
    			  .ALUSrc2(c_alu_src2),
    			  .ALUOp(c_alu_op),
    			  .MemWrite(c_mem_write),
    			  .MemRead(c_mem_read),
    			  .early_branch_sel(early_branch_selector),
    			  .MemToReg(c_mem_to_reg));
    			  
    mux2to1 write_back_mux (.sel(MEM_WB_WBcntrl_out[2]),//instead of c_jump
    			    .input0(d_mem_mux_out),
    			    .input1(MEM_WB_pc_plus_4_out),
    			    .muxout(d_reg_file_datain));
    			    
    regfile RF_inst (.clk(clk),
    		     .rst_n(rst_n),
    		     .RegWrite(MEM_WB_WBcntrl_out[1]),//intstead of c_reg_write
    		     .rs1(d_rs1),
    		     .rs2(d_rs2),
    		     .rd(MEM_WB_RD),//d_rd
    		     .datain(d_reg_file_datain),
    		     .regA(d_regA),
    		     .regB(d_regB));
    		     
    branch_cmp brcmp_inst (.inputA(branchcmp_inp_A),
    			   .inputB(branchcmp_inp_B),
    			   .cond(d_funct3),
    			   .result(c_branch_out));
    			   
    immgen immgen_inst (.instruction(IF_ID_d_instr_word_out),
    			.immediate(d_immediate));
    			
    mux2to1 lui_mux (.sel(c_lui),
    		     .input0(IF_ID_pc_out),
    		     .input1(d_zero),
    		     .muxout(d_lui_mux_out));
    		     
    mux2to1 alu_src1_mux (.sel(ID_EX_EXcntrl_out[0]),//instead of c_alu_src1
    			  .input0(alu_input1),
    			  .input1(ID_EX_lui_result_out),
    			  .muxout(d_alu_src1));
    			  
    mux2to1 alu_src2_mux (.sel(ID_EX_EXcntrl_out[1]),//instead of c_alu_src2
    			  .input0(alu_input2),
    			  .input1(ID_EX_immgen_result_out),
    			  .muxout(d_alu_src2));
    			 
    mux2to1 mem_mux (.sel(MEM_WB_WBcntrl_out[0]),//instead of c_mem_to_reg
                     .input0(MEM_WB_alu_out),
                     .input1(MEM_WB_data_out),
                     .muxout(d_mem_mux_out));
                     
    alu alu_inst (.inputA(d_alu_src1),
                  .inputB(d_alu_src2),
                  .ALUop(ID_EX_EXcntrl_out[5:2]),//c_alu_op
                  .result(d_alu_out));
    			
    lmb ldmb_inst (.proc_addr(EX_MEM_alu_out),
    		   .proc_data_send(EX_MEM_regB),//should be corrected
    		   .proc_data_receive(d_data_mem_out),
    		   .proc_byte_mask(d_byte_mask),
    		   .proc_sign_ext_n(d_sign_ext_n),
    		   .proc_mem_write(EX_MEM_MEMcntrl_out[0]),//c_mem_write
    		   .proc_mem_read(EX_MEM_MEMcntrl_out[1]),//c_mem_read
    		   .mem_addr(dmem_addr),
    		   .mem_datain(dmem_datain),
    		   .mem_dataout(dmem_dataout),
    		   .mem_wen(dmem_wen),
    		   .mem_ben(dmem_ben));
    		   
    // new code 
    
    ForwardingUnit fwd_inst (.EX_MEM_Rd(EX_MEM_RD),
                       .MEM_WB_Rd(MEM_WB_RD),
                       .ID_EX_Rs1(ID_EX_RS1),
                       .ID_EX_Rs2(ID_EX_RS2),
                       .IF_ID_Rs1(d_rs1),
                       .IF_ID_Rs2(d_rs2),
                       .EX_MEM_reg_write(EX_MEM_WBcntrl_out[1]),//new
                       .MEM_WB_reg_write(MEM_WB_WBcntrl_out[1]),//new
                       //.Stage(Stage_sel),
                       .hit_exmem(Hit_exmem),//new
                       .hit_memwb(Hit_memwb),//new
                       .R1(R1_sel),
                       .R2(R2_sel),
                       .branch_R1(R1_branchcmp),
                       .branch_R2(R2_branchcmp));
                       
    Branch_Adder BranchAdder (.input_A(early_branch_output),//IF_ID_pc_out
                       .input_B(d_immediate),
                       .result(targetPC));
                       
    mux2to1 Stage_mux (.sel(Hit_memwb && !Hit_exmem), //needs to chsnge // selector= hit memwb & !hit ex mem Stage_sel
    			  .input0(mem_stage_mux),//EX_MEM_alu_out //mem_stage_mux
    			  .input1(d_reg_file_datain),//d_mem_mux_out //d_reg_file_datain//
    			  .muxout(Stage_output));
    
    mux2to1 R1_sel_mux (.sel(R1_sel),//do we need these??//
    			  .input0(ID_EX_regA),
    			  .input1(Stage_output),
    			  .muxout(alu_input1));
    
    mux2to1 R2_sel_mux (.sel(R2_sel),//this also??//
    			  .input0(ID_EX_regB),
    			  .input1(Stage_output),
    			  .muxout(alu_input2));
        			    			  
    mux2to1 branch_A (.sel(R1_branchcmp), // ID stage
    			  .input0(d_regA),
    			  .input1(Stage_output),
    			  .muxout(branchcmp_inp_A));
   
    mux2to1 branch_B (.sel(R2_branchcmp), // ID stage
    			  .input0(d_regB),
    			  .input1(Stage_output),
    			  .muxout(branchcmp_inp_B));
    
    mux2to1 control_mux (.sel(flush_signal|| flush_current),// not sure if it is correct /or needed
                    .input0(input_control_wires),
                    .input1(32'b0),
                    .muxout(output_control_wires));
                    
    //new mux
    mux2to1 early_branch_mux (.sel(early_branch_selector),//still wrong but IG we need it incase we had a JalR instructions were we require reg A instead of lui_mux_out
                    .input0(branchcmp_inp_A), 
                    .input1(d_lui_mux_out),
                    .muxout(early_branch_output));
                    
    mux2to1 mem_mux_2 (.sel(EX_MEM_WBcntrl_out[0]),//instead of c_mem_to_reg
                     .input0(EX_MEM_alu_out),
                     .input1(d_data_mem_out),
                     .muxout(mem_stage_mux));	  
    			      			 			  
    hdu hdu_inst (.ID_EX_MemRead(ID_EX_MEMcntrl_out[1]),
                  .ID_EX_RegisterRd(ID_EX_RD),
                  .IF_ID_RegisterRs1(d_rs1),
                  .IF_ID_RegisterRs2(d_rs2),
                  .PCSrc(c_PCSrc),//c_PCSrc
                  .PCWrite(PCwrite),
                  .IF_ID_Write(IF_ID_write),
                  .FlushSel(flush_sel),
                  .Flush_current(flush_current) 
    );
    
    IF_ID_Datapath_Register IF_ID (.clk(clk),
                             .reset(rst_n),
                             .IF_ID_Write(IF_ID_write),
                             .flush_in(flush_sel),
                             .pc_in(d_pc_out),
                             .pc_plus4_in(d_pcplus4),
                             .d_instr_word_in(d_instr_word),  
                             .pc_out(IF_ID_pc_out),
                             .pc_plus4_out(IF_ID_pc_plus4_out),
                             .flush_out(flush_signal),
                             .d_instr_word_out(IF_ID_d_instr_word_out));
                             
    ID_EX_Datapath_Register ID_EX (.clk(clk),
                             .reset(rst_n),
                             .IF_ID_Rs1(d_rs1),
                             .IF_ID_Rs2(d_rs2),
                             .IF_ID_Rd(d_rd),
                             .reg_file_regA(branchcmp_inp_A),//d_regA
                             .reg_file_regB(branchcmp_inp_B),//d_regB
                             .immgen_result_in(d_immediate),
                             .func3_in(d_funct3),
                             .pc_in(IF_ID_pc_plus4_out),//changed
                             .lui_result_in(d_lui_mux_out),
                             //.branch_target(targetPC),//new
                             //.pc_src_sel(c_PCSrc),//new
                             .WB_inp_cntrl(WB_control_wires_out),
                             .Mem_inp_cntrl(MEM_control_wires_out),
                             .Ex_inp_cntrl(EX_control_wires_out),
                             .WB_out_cntrl(ID_EX_WBcntrl_out),
                             .Mem_out_cntrl(ID_EX_MEMcntrl_out),
                             .Ex_out_cntrl(ID_EX_EXcntrl_out),
                             .ID_EX_Rs1(ID_EX_RS1),
                             .ID_EX_Rs2(ID_EX_RS2),
                             .ID_EX_Rd(ID_EX_RD),
                             .ID_EX_regA(ID_EX_regA),
                             .ID_EX_regB(ID_EX_regB),
                             .immgen_result_out(ID_EX_immgen_result_out),
                             .func3_out(ID_EX_funct3_out),
                             .pc_out(ID_EX_pc_plus_4_out),
                             //.branch_target_out(targetPC_out),
                             //.pc_src_sel_out(PC_src_out),
                             .lui_result_out(ID_EX_lui_result_out));
                             
    EX_MEM_Datapath_Register EX_MEM (.clk(clk),
                             .reset(rst_n),
                             .EX_MEM_Rd_in(ID_EX_RD),
                             .reg_file_regB(alu_input2),//ID_EX_regB //needs to change
                             .func3_in(ID_EX_funct3_out),
                             .pc_in(ID_EX_pc_plus_4_out),
                             .ALU_result_in(d_alu_out),
                             .WB_inp_cntrl(ID_EX_WBcntrl_out),
                             .Mem_inp_cntrl(ID_EX_MEMcntrl_out),
                             .WB_out_cntrl(EX_MEM_WBcntrl_out),
                             .Mem_out_cntrl(EX_MEM_MEMcntrl_out),
                             .EX_MEM_Rd_out(EX_MEM_RD),
                             .EX_MEM_regB(EX_MEM_regB),
                             .func3_out(EX_MEM_funct3_out),
                             .pc_out(EX_MEM_pc_plus_4_out),
                             .ALU_result_out(EX_MEM_alu_out));        

    MEM_WB_Datapath_Register MEM_WB (.clk(clk),
                             .reset(rst_n),
                             .MEM_WB_Rd_in(EX_MEM_RD),
                             .func3_in(EX_MEM_funct3_out),
                             .pc_in(EX_MEM_pc_plus_4_out),
                             .ALU_result_in(EX_MEM_alu_out),
                             .data_inp(d_data_mem_out),
                             .WB_inp_cntrl(EX_MEM_WBcntrl_out),
                             .WB_out_cntrl(MEM_WB_WBcntrl_out),
                             .MEM_WB_Rd_out(MEM_WB_RD),
                             .func3_out(MEM_WB_funct3_out),
                             .pc_out(MEM_WB_pc_plus_4_out),
                             .ALU_result_out(MEM_WB_alu_out),
                             .data_out(MEM_WB_data_out));
                                			  

    assign d_rs1 = IF_ID_d_instr_word_out[`LOG2_XRF_SIZE+14:15];   
    assign d_rs2 = IF_ID_d_instr_word_out[`LOG2_XRF_SIZE+19:20];
    assign d_rd = IF_ID_d_instr_word_out[`LOG2_XRF_SIZE+6:7];
    assign d_funct3 = IF_ID_d_instr_word_out[14:12];
    assign d_funct7 = IF_ID_d_instr_word_out[31:25];
    
    //assign d_rs1 = d_instr_word[`LOG2_XRF_SIZE+14:15];
    //assign d_rs2 = d_instr_word[`LOG2_XRF_SIZE+19:20];
    //assign d_rd = d_instr_word[`LOG2_XRF_SIZE+6:7];
    //assign d_funct3 = d_instr_word[14:12];
    //assign d_funct7 = d_instr_word[31:25];
    
    assign d_zero = `XLEN'd0;
    assign d_byte_mask = d_funct3[1:0];
    assign d_sign_ext_n = d_funct3[2];
    

    
   //assign PCsrctest=PC_src_out ;//test
   assign PCsrctest= c_PCSrc;
   //assign PCsrctest=IF_ID_pc_plus4_out ;//test
   //assign PCsrctest=EX_MEM_MEMcntrl_out[0] ;//test
   //assign PCsrctest=MEM_control_wires_out;
endmodule

