`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/10/2025 01:10:28 PM
// Design Name: 
// Module Name: Branch Adder
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
module Branch_Adder(//ID stage
    input [`XLEN-1:0] input_A,//PC from d_lui_muxout
    input [`XLEN-1:0] input_B,//immediate
	output [`XLEN-1:0] result //target location
    );
    assign result=$signed(input_A) +$signed(input_B);
endmodule