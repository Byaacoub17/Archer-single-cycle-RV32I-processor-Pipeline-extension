`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AUB
// Engineer:
//
// Create Date: 07/10/2025 09:03:13 AM
// Design Name:
// Module Name: hdu
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
module hdu(
    input ID_EX_MemRead, // checks if instruction is load or not
    input [`LOG2_XRF_SIZE-1:0] ID_EX_RegisterRd,
    input [`LOG2_XRF_SIZE-1:0] IF_ID_RegisterRs1,
    input [`LOG2_XRF_SIZE-1:0] IF_ID_RegisterRs2,
    input PCSrc,
   
    output reg PCWrite, // if 0 stall PC
    output reg IF_ID_Write, // if 0 stall IF/ID register
    output reg FlushSel, // if 0 do nothing, if 1 insert NOP
    output reg Flush_current//maybe not needed
   


);
    always @(*)
    begin // no hazards
        PCWrite = 1; // update PC
        IF_ID_Write = 1; // update IF/ID
        FlushSel = 0; // nothing
        Flush_current = 0;
        if (ID_EX_MemRead && ((ID_EX_RegisterRd == IF_ID_RegisterRs1) || (ID_EX_RegisterRd == IF_ID_RegisterRs2)))
        begin // hazard detected (stall) for load-use data hazard
            PCWrite = 0; // stall PC
            IF_ID_Write = 0; // stall IF/ID (stays in decode instruction)
            Flush_current = 1; // inserts NOP
        end
       
        // branch taken (control hazard)
        else if (PCSrc)
        begin
            FlushSel = 1; // flush IF/ID (speculative wrong-path instruction)
        end
    end
           
   
   
   
   
   
   
endmodule
