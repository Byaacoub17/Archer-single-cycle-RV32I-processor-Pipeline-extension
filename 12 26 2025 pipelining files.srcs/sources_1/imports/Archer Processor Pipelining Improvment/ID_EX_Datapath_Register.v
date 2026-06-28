`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2025 11:32:16 PM
// Design Name: 
// Module Name: ID-EX-datapath-reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "archerdefs.v"
module ID_EX_Datapath_Register(
    input clk,//add clk to transfer data each clock cycle
	input reset,//reset to clear reg file in case of flushing pipeline 
    input [`LOG2_XRF_SIZE-1:0] IF_ID_Rs1,//rename as ID RS1...//correct size: not 32 bits!!!
	input [`LOG2_XRF_SIZE-1:0] IF_ID_Rs2,
	input [`LOG2_XRF_SIZE-1:0] IF_ID_Rd,
	input [`XLEN-1:0] reg_file_regA,
	input [`XLEN-1:0] reg_file_regB,
	
	input [`XLEN-1:0] immgen_result_in, // check this out
	input [2:0] func3_in,
	input [`XLEN-1:0] pc_in,  //result of add4???
	input [`XLEN-1:0] lui_result_in, 
	//input [`XLEN-1:0] branch_target,
	//input pc_src_sel,
	// input control signals
	input [2:0] WB_inp_cntrl, //c jump/ c reg write/ reset/ c mem to reg
	input [1:0] Mem_inp_cntrl, //c mem write/c mem read
	input [5:0] Ex_inp_cntrl,//alusrc1/ alu op/ alusrc2/
	
	//output control signals
	output [2:0] WB_out_cntrl, //c jump/ c reg write/ reset/ c mem to reg
	output  [1:0] Mem_out_cntrl, //c mem write/c mem read
	output [5:0] Ex_out_cntrl,//alusrc1/ alu op/ alusrc2/
	
	// output registers
	output [`LOG2_XRF_SIZE-1:0] ID_EX_Rs1,//rename as EX RS1....
	output [`LOG2_XRF_SIZE-1:0] ID_EX_Rs2,
	output [`LOG2_XRF_SIZE-1:0] ID_EX_Rd,
	output [`XLEN-1:0] ID_EX_regA,
	output [`XLEN-1:0] ID_EX_regB,
	
	output [`XLEN-1:0] immgen_result_out,
	output [2:0] func3_out, //passing on the branch cmp from immgen_in to the next stage// **pass it on through control signals
	output [`XLEN-1:0] pc_out,
	output [`XLEN-1:0] lui_result_out
	//output [`XLEN-1:0] branch_target_out,
	//output pc_src_sel_out
	);
	reg [`LOG2_XRF_SIZE-1:0] rs1,rs2,rd;
	reg [`XLEN-1:0] regA,regB,immgen,pc,lui_result;//,branch
	reg [2:0] wb;
	reg [1:0] mem;
	reg [5:0] ex;
	reg [2:0] func3;
	//reg PCsrc;
	
	always @ (posedge clk ) begin//or reset
	   if (!reset) begin
	       rs1<=`LOG2_XRF_SIZE'b0;
	       rs2<=`LOG2_XRF_SIZE'b0;
	       rd<=`LOG2_XRF_SIZE'b0;
	       regA<=`XLEN'b0;
	       regB<=`XLEN'b0;
	       immgen<=`XLEN'b0;
	       wb<=3'b0;
	       mem<=2'b0;
	       ex<=6'b0;
	       func3<=3'b0;
	       pc<=`XLEN'b0;
	       lui_result<=`XLEN'b0;
	       //branch<=`XLEN'b0;
	       //PCsrc<=1'b0;
           end
      else begin
           rs1<=IF_ID_Rs1;
	       rs2<=IF_ID_Rs2;
	       rd<=IF_ID_Rd;
	       regA<=reg_file_regA;
	       regB<=reg_file_regB;
	       immgen<=immgen_result_in;
	       wb<=WB_inp_cntrl;
	       mem<=Mem_inp_cntrl;
	       ex<=Ex_inp_cntrl;
	       func3<=func3_in;
	       pc<=pc_in;
	       lui_result<=lui_result_in;
	       //branch<=branch_target;
	       //PCsrc<=pc_src_sel;
           end 
   end 
assign ID_EX_Rs1=rs1;
assign ID_EX_Rs2=rs2;
assign ID_EX_Rd=rd;
assign ID_EX_regA=regA;
assign ID_EX_regB=regB;
assign immgen_result_out=immgen;
assign WB_out_cntrl=wb;
assign Mem_out_cntrl=mem;
assign Ex_out_cntrl=ex;
assign func3_out=func3; //passing func3
assign pc_out=pc;
assign lui_result_out=lui_result;
//assign branch_target_out=branch;
//assign pc_src_sel_out=pc_src_sel;       
        	
endmodule

