/* Address bus size*/
`define A_SIZE 10

/* Data bus size*/
`define D_SIZE 32

/* Instruction size*/
`define I_SIZE 16

/*CPU Registers*/
`define R_NUM 8
`define R_SIZE 3
`define R0 3'd0
`define R1 3'd1
`define R2 3'd2
`define R3 3'd3
`define R4 3'd4
`define R5 3'd5
`define R6 3'd6
`define R7 3'd7

/*OPCODES*/
`define ARITHMETIC 2'b00
`define SHIFT      2'b01
`define MEM        2'b10
`define COND       2'b11

/*ARITHMETIC*/
`define ADD      4'b0001
`define ADDF     4'b0010
`define SUB      4'b0011
`define SUBF     4'b0100
`define AND      4'b0101
`define OR       4'b0110
`define XOR      4'b0111
`define NAND     4'b1000
`define NXOR     4'b1001

/*SHIFT*/
`define SHIFTR   4'b0000
`define SHIFTRA  4'b0001
`define SHIFTL   4'b0010

/*MEM*/
`define LOAD     4'b0000
`define LOADC    4'b0001
`define STORE    4'b0010

/*COND*/
`define JMP      4'b1100
`define JMPR     4'b1101
`define JMPcond  4'b1110
`define JMPRcond 4'b1111


`define HALT     16'hFFFF
`define NOP      16'h0000

/*OPCODES*/
`define OP_SIZE 4
`define OP_TYPE 2