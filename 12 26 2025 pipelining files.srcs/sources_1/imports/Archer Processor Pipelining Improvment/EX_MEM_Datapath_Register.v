`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 01:29:51 PM
// Design Name: 
// Module Name: EX_MEM_Datapath_Register
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


module EX_MEM_Datapath_Register(
    input clk,//add clk to transfer data each clock cycle
	input reset,//reset to clear reg file in case of flushing pipeline 
    
	input [`LOG2_XRF_SIZE-1:0] EX_MEM_Rd_in,
	input [`XLEN-1:0] reg_file_regB,
	
	input [2:0] func3_in, // might want to pass it through control signals **
	input [`XLEN-1:0] pc_in,  //result of add4???
	input [`XLEN-1:0] ALU_result_in,
	// input control signals
	input [2:0] WB_inp_cntrl, //c jump/ c reg write /c mem to reg //////reset not needed
	input [1:0] Mem_inp_cntrl, //c mem write/c mem read
	
	//output control signals
	output [2:0] WB_out_cntrl, //c jump/ c reg write/ c mem to reg ///// reset not needed
	output  [1:0] Mem_out_cntrl, //c mem write/c mem read
	
	// output registers
	output [`LOG2_XRF_SIZE-1:0] EX_MEM_Rd_out,
	output [`XLEN-1:0] EX_MEM_regB,
	
	output [2:0] func3_out, //passing on the branch cmp from immgen_in to the next stage
	output [`XLEN-1:0] pc_out,
	output [`XLEN-1:0] ALU_result_out
	);
	reg [`LOG2_XRF_SIZE-1:0] rd;
	reg [`XLEN-1:0] regB,pc,alu;
	reg [2:0] wb;
	reg [1:0] mem;
	reg [2:0] func3;
	
	always @ (posedge clk ) begin//or reset
        if (!reset) begin
	       rd<=`LOG2_XRF_SIZE'b0;
	       regB<=`XLEN'b0;
	       wb<=3'b0;
	       mem<=2'b0;
	       func3<=3'b0;
	       pc<=`XLEN'b0;
	       alu<=`XLEN'b0;
           end
        else begin
	       rd<=EX_MEM_Rd_in;
	       regB<=reg_file_regB;
	       wb<=WB_inp_cntrl;
	       mem<=Mem_inp_cntrl;
	       func3<=func3_in;
	       pc<=pc_in;
	       alu<=ALU_result_in;
           end 
    end 
assign EX_MEM_Rd_out=rd;
assign EX_MEM_regB=regB;
assign WB_out_cntrl=wb;
assign Mem_out_cntrl=mem;
assign func3_out=func3; //passing func3
assign pc_out=pc;
assign ALU_result_out=alu;   

endmodule
