`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 01:35:51 PM
// Design Name: 
// Module Name: MEM_WB_Datapath_Register
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
module MEM_WB_Datapath_Register(

    input clk,//add clk to transfer data each clock cycle
	input reset,//reset to clear reg file in case of flushing pipeline 
    
	input [`LOG2_XRF_SIZE-1:0] MEM_WB_Rd_in,
	
	input [2:0] func3_in,
	input [`XLEN-1:0] pc_in,  //result of add4
	
	input [`XLEN-1:0] ALU_result_in,
	input [`XLEN-1:0] data_inp, // coming from data mem
	
	// input control signals
	input [2:0] WB_inp_cntrl, //c jump/ c reg write/  c mem to reg
	
	//output control signals
	output [2:0] WB_out_cntrl, //c jump/ c reg write/  c mem to reg
	
	// output registers
	output [`LOG2_XRF_SIZE-1:0] MEM_WB_Rd_out,
	// output [`XLEN-1:0] MEM_WB_regB, not needed
	
	output [2:0] func3_out, //passing on the branch cmp from immgen_in to the next stage || could be passed from control signals
	output [`XLEN-1:0] pc_out,
	output [`XLEN-1:0] ALU_result_out,
	output [`XLEN-1:0] data_out
	);
	reg [`LOG2_XRF_SIZE-1:0] rd;
	reg [`XLEN-1:0] pc,alu,data;//regB,
	reg [2:0] wb;
	reg [2:0] func3;
	
	always @ (posedge clk ) begin//or instead of |//or reset
	   if (!reset) begin
	       rd<=`LOG2_XRF_SIZE'b0;
	       wb<=3'b0;
	       func3<=3'b0;
	       pc<=`XLEN'b0;
	       alu<=`XLEN'b0;
	       data<=`XLEN'b0;
           end
      else begin
	       rd<=MEM_WB_Rd_in;
	       wb<=WB_inp_cntrl;
	       func3<=func3_in;
	       pc<=pc_in;
	       alu<=ALU_result_in;
	       data<=data_inp;
           end 
   end 
assign MEM_WB_Rd_out=rd;
assign WB_out_cntrl=wb;
assign func3_out=func3; //passing func3
assign pc_out=pc;
assign ALU_result_out=alu;
assign data_out=data;      
        	
endmodule
