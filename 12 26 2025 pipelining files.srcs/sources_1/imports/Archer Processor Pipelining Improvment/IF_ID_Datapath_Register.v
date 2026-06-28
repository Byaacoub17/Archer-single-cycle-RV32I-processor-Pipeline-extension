`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2025 12:16:15 PM
// Design Name: 
// Module Name: IF_ID_Datapath_Register
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
module IF_ID_Datapath_Register(
    input clk,//add clk to transfer data each clock cycle
	input reset,//reset to clear reg file in case of flushing pipeline
    input IF_ID_Write,
	input flush_in,
	input [`XLEN-1:0] pc_in,
	input [`XLEN-1:0] d_instr_word_in,
	input [`XLEN-1:0] pc_plus4_in,

	// output registers
	output [`XLEN-1:0] pc_out,
	output [`XLEN-1:0] d_instr_word_out,
	output [`XLEN-1:0] pc_plus4_out,
	output flush_out

	);
	reg [`XLEN-1:0] pc,instr_word,pc_plus4;
	reg flush;
	
	always @ (posedge clk ) begin//or reset
	  if (!reset) begin
	      pc<=`XLEN'b0;
	      pc_plus4<=`XLEN'b0;
	      instr_word<=`XLEN'b0;
	      flush<=1'b0;
          end
      else if (IF_ID_Write) begin // when IF_ID is 1
          pc<=pc_in;
          pc_plus4<=pc_plus4_in;
          instr_word<=d_instr_word_in;
          flush<=flush_in;
      end 
    end 

assign pc_out=pc;
assign pc_plus4_out=pc_plus4;
assign d_instr_word_out=instr_word;
assign flush_out=flush;
endmodule
