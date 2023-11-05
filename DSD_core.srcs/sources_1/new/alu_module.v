`timescale 1ns / 1ps
`include "macros.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2023 09:29:21 PM
// Design Name: 
// Module Name: alu_module
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


module alu_module(
    input [`D_SIZE-1:0] op1,
    input [`D_SIZE-1:0] op2,
    input [`OP_TYPE-1:0] optype,
    input [`OP_SIZE-1:0] opcode,
    output reg [`D_SIZE-1:0] result
    );
    
always@(op1, op2, opcode, optype) begin
    if (optype == `ARITHMETIC) begin
        case (opcode)
            `ADD:
                result = op1 + op2;
            `ADDF:
                result = op1 + op2;
            `SUB:
                result = op1 - op2;
            `SUBF:
                result = op1 - op2;
            `AND:
                result = op1 & op2;
            `OR:
                result = op1 || op2;
            `XOR:
                result = op1 ^ op2;
            `NAND:
                result = ~(op1 & op2);
            `NXOR:
                result = ~(op1 || op2);
        endcase
    end else if (optype == `SHIFT) begin
        case (opcode)
            `SHIFTR:
                result = op1 >> op2;
            `SHIFTRA:
                result = op1 >>> op2;
            `SHIFTL:
                result = op1 << op2;
        endcase
    end
end
endmodule
