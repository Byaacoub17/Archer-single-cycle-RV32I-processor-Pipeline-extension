`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2025 09:07:34 AM
// Design Name: 
// Module Name: ForwardingUnit
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
module ForwardingUnit(
    input [`LOG2_XRF_SIZE-1:0] EX_MEM_Rd,
    input [`LOG2_XRF_SIZE-1:0] MEM_WB_Rd,
    input [`LOG2_XRF_SIZE-1:0] ID_EX_Rs1,
    input [`LOG2_XRF_SIZE-1:0] ID_EX_Rs2,
    input [`LOG2_XRF_SIZE-1:0] IF_ID_Rs1,//new
    input [`LOG2_XRF_SIZE-1:0] IF_ID_Rs2,//new
    input EX_MEM_reg_write,
    input MEM_WB_reg_write,
    //output Stage,//change name and add another output (hit_exmem,hit_memwb)
    output hit_exmem,
    output hit_memwb,
    output R1,
    output R2,
    output branch_R1,//new
    output branch_R2//new
    );
    
    assign R1 = (((ID_EX_Rs1 == EX_MEM_Rd) && EX_MEM_reg_write && EX_MEM_Rd!=5'b0) || ((ID_EX_Rs1 == MEM_WB_Rd) && MEM_WB_reg_write && MEM_WB_Rd!=5'b0)) ? 1'b1 : 1'b0; // to know wether Rs1 or Rs2
    assign R2 = (((ID_EX_Rs2 == EX_MEM_Rd) && EX_MEM_reg_write && EX_MEM_Rd!=5'b0) || ((ID_EX_Rs2 == MEM_WB_Rd) &&  MEM_WB_reg_write && MEM_WB_Rd!=5'b0)) ? 1'b1 : 1'b0;
    
    assign branch_R1 = (((IF_ID_Rs1 == EX_MEM_Rd) && EX_MEM_reg_write && EX_MEM_Rd!=5'b0) || ((IF_ID_Rs1 == MEM_WB_Rd) &&  MEM_WB_reg_write && MEM_WB_Rd!=5'b0)) ? 1'b1 : 1'b0; // to know wether Rs1 or Rs2
    assign branch_R2 = (((IF_ID_Rs2 == EX_MEM_Rd) && EX_MEM_reg_write && EX_MEM_Rd!=5'b0) || ((IF_ID_Rs2 == MEM_WB_Rd) &&  MEM_WB_reg_write && MEM_WB_Rd!=5'b0)) ? 1'b1 : 1'b0;
    
    //assign Stage = ((ID_EX_Rs1 == EX_MEM_Rd || ID_EX_Rs2 == EX_MEM_Rd) && EX_MEM_reg_write && EX_MEM_Rd!=5'b0) ? 1'b0 : 1'b1; // if we are in the EX_MEM stage 
    assign hit_exmem = EX_MEM_reg_write && (EX_MEM_Rd != 5'd0) &&
                 ((ID_EX_Rs1 == EX_MEM_Rd) || (ID_EX_Rs2 == EX_MEM_Rd) ||
                  (IF_ID_Rs1 == EX_MEM_Rd) || (IF_ID_Rs2 == EX_MEM_Rd));

    assign hit_memwb = MEM_WB_reg_write && (MEM_WB_Rd != 5'd0) &&
                 ((ID_EX_Rs1 == MEM_WB_Rd) || (ID_EX_Rs2 == MEM_WB_Rd) ||
                  (IF_ID_Rs1 == MEM_WB_Rd) || (IF_ID_Rs2 == MEM_WB_Rd));


endmodule
