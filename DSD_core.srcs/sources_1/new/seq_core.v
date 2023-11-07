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
reg [6:0] opcode;
wire [`D_SIZE-1:0] result;
alu_module alu(
    .op1(op1),
    .op2(op2),
    .opcode(opcode),
    .result(result)
);

/*CPU signals*/
reg [`A_SIZE-1:0] pc_next;

/*Decoding current instruction*/
always@(*) begin
    pc_next = pc;
    op1 = 0;
    op2 = 0;
    register_read1_addr = 0;
    register_read2_addr = 0;
    if (instruction == `NOP) begin
        pc_next = pc + 1;
    end else if (instruction == `HALT) begin
        pc_next = pc;
    end else if (instruction[15:14] == `ARITHMETIC) begin
        pc_next = pc + 1;
        opcode = instruction[15:9];
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
        pc_next = pc + 1;
        opcode = instruction[15:9];
        register_write_addr = instruction[8:6]; // op0
        /*read from register*/
        register_read1_addr = instruction[8:6]; // op1
        /*pass values to ALU*/
        op1 = register_data1_out;
        op2 = instruction[5:0];
        /*store the result*/
        register_data_in = result;
    end else if (instruction[15:14] == `MEM) begin
        pc_next = pc + 1;
        if (instruction[15:11] == `LOADC) begin
            register_read1_addr = instruction[10:8];
            register_write_addr = instruction[10:8];
            register_data_in = {register_data1_out[`D_SIZE-1:8], instruction[7:0]};
        end
    end else if (instruction[15:14] == `COND) begin
        case (instruction[15:12])
            `JMP: begin
                register_read1_addr = instruction[2:0];
                pc_next = register_data1_out[`A_SIZE:0];
             end
            `JMPR: begin
                pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
             end
             `JMPcond: begin
                /*read op0*/
                register_read1_addr = instruction[8:6];
                /*read op1*/
                register_read2_addr = instruction[2:0];
                case (instruction[11:9])
                   `N: begin
                        if (register_data1_out[`D_SIZE-1] == 1'b1) begin
                            pc_next = pc + register_data2_out[`A_SIZE-1:0];
                        end
                    end
                    `NN: begin
                        if (register_data1_out[`D_SIZE-1] == 1'b0) begin
                            pc_next = pc + register_data2_out[`A_SIZE-1:0];
                        end
                    end
                    `Z: begin
                        if (register_data1_out == `D_SIZE'd0) begin
                            pc_next = pc + register_data2_out[`A_SIZE-1:0];
                        end
                    end
                    `NZ: begin
                        if (register_data1_out != `D_SIZE'd0) begin
                            pc_next = pc + register_data2_out[`A_SIZE-1:0];
                        end
                    end
                endcase
             end
             `JMPRcond: begin
                /*read op0*/
                register_read1_addr = instruction[8:6];
                case (instruction[11:9])
                   `N: begin
                        if (register_data1_out[`D_SIZE-1] == 1'b1) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end
                    end
                    `NN: begin
                        if (register_data1_out[`D_SIZE-1] == 1'b0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end
                    end
                    `Z: begin
                        if (register_data1_out == `D_SIZE'd0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end
                    end
                    `NZ: begin
                        if (register_data1_out != `D_SIZE'd0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end
                    end
                endcase
             end
        endcase
    end else begin
        pc_next = pc;
    end
end

always@(posedge clk) begin
/*Update program counter for accessing next instruction*/
    register_write_enable = 1'b0;
    if(rst == 1'b1) begin
        pc <= pc_next;
        if(instruction[15:14] == `ARITHMETIC || instruction[15:14] == `SHIFT || instruction[15:14] == `MEM) begin
            register_write_enable = 1'b1;
        end
    end else begin
        pc <= 0;
        pc_next <= 0;
    end
end

endmodule
