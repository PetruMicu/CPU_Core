`timescale 1ns / 1ps
`include "macros.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2023 07:03:47 PM
// Design Name: 
// Module Name: seq_core
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

module seq_core(
    // general
    input                    rst,   // active 0
    input                    clk,
    // program memory
    output reg [`A_SIZE-1:0] pc,
    input      [15:0]        instruction,
    // data memory
    output reg               read,  // active 1
    output reg               write, // active 1
    output reg [`A_SIZE-1:0] address,
    input      [`D_SIZE-1:0] data_in,
    output reg [`D_SIZE-1:0] data_out
);

/*Internal registers signals*/
reg register_write_enable;
reg [`R_SIZE-1:0] register_write_addr;
reg [`R_SIZE-1:0] register_read1_addr;
reg [`R_SIZE-1:0] register_read2_addr;
reg [`D_SIZE-1:0] register_data_in;
wire [`D_SIZE-1:0] register_data1_out;
wire [`D_SIZE-1:0] register_data2_out;
reg_module registers(
    .rst(rst),
    .clk(clk),
    .write_enable(register_write_enable),
    .write_addr(register_write_addr),
    .read1_addr(register_read1_addr),
    .read2_addr(register_read2_addr),
    .data_in(register_data_in),
    .data1_out(register_data1_out),
    .data2_out(register_data2_out)
);

/*ALU signals*/
reg [`D_SIZE-1:0] op1;
reg [`D_SIZE-1:0] op2;
reg [`OP_SIZE-1:0] opcode;
wire [`D_SIZE-1:0] result;
alu_module alu(
    .op1(op1),
    .op2(op2),
    .opcode(opcode),
    .optype(instruction[15:14]),
    .result(result)
);

/*CPU signals*/
reg [`A_SIZE-1:0] pc_next;

/*Decoding current instruction*/
always@(instruction, pc, register_data1_out, register_data2_out, result) begin
    if (instruction == `NOP) begin
        pc_next = pc + 1;
    end else if (instruction == `HALT) begin
        pc_next = pc;
    end else if (instruction[15:14] == `ARITHMETIC) begin
        opcode = instruction[12:9];
        register_write_addr = instruction[8:6]; // op0
        /*read from registers*/
        register_read1_addr = instruction[5:3]; // op1
        register_read2_addr = instruction[2:0]; // op1
        /*pass register values to ALU*/
        op1 = register_data1_out;
        op2 = register_data2_out;
        /*store the result*/
        register_data_in = result;
    end else if(instruction[15:14] == `SHIFT) begin
        opcode = instruction[12:9];
        register_write_addr = instruction[8:6]; // op0
        /*read from register*/
        register_read1_addr = instruction[8:6]; // op1
        /*pass values to ALU*/
        op1 = register_data1_out;
        op2 = instruction[5:0];
        /*store the result*/
        register_data_in = result;

    end else if (instruction[15:14] == `MEM) begin

    end else if (instruction[15:14] == `COND) begin
        
    end
end

always@(posedge clk) begin
/*Update program counter for accessing next instruction*/
    if(rst == 1'b1) begin
        pc <= pc_next;
        if(instruction[15:14] == `ARITHMETIC || instruction[15:14] == `SHIFT || instruction[15:14] == `MEM) begin
            register_write_enable = 1'b1;
        end
   end else begin
        pc <= 0;
        pc_next = 0;
   end
end

endmodule
