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
reg [`D_SIZE-1:0] register_data_in;

/*CPU signals*/
reg [`A_SIZE-1:0] pc_next;
reg [`D_SIZE-1:0] registers [0:`R_NUM-1]; // 8 internal registers R0 to R7
integer idx;

/*Decoding current instruction*/
always@(*) begin
    pc_next = pc;
    read = 0;
    write = 0;
    address = 0;
    data_out = 0;
    register_data_in = 0;
    register_write_addr = 0;
    if (instruction == `NOP) begin
        pc_next = pc + 1;
    end else if (instruction == `HALT) begin
        pc_next = pc;
    end else if (instruction[15:14] == `ARITHMETIC) begin
        pc_next = pc + 1;
        /*read from registers*/
        register_write_addr = instruction[8:6]; // op0
        case (instruction[15:9])
            `ADD:
                register_data_in = registers[instruction[5:3]] + registers[instruction[2:0]];
            `ADDF:
                register_data_in = registers[instruction[5:3]] + registers[instruction[2:0]];
            `SUB:
                register_data_in = registers[instruction[5:3]] - registers[instruction[2:0]];
            `SUBF:
                register_data_in = registers[instruction[5:3]] - registers[instruction[2:0]];
            `AND:
                register_data_in = registers[instruction[5:3]] & registers[instruction[2:0]];
            `OR:
                register_data_in = registers[instruction[5:3]] || registers[instruction[2:0]];
            `XOR:
                register_data_in = registers[instruction[5:3]] ^ registers[instruction[2:0]];
            `NAND:
                register_data_in = ~(registers[instruction[5:3]] & registers[instruction[2:0]]);
            `NXOR:
                register_data_in = ~(registers[instruction[5:3]] || registers[instruction[2:0]]);
        endcase
    end else if(instruction[15:14] == `SHIFT) begin
        pc_next = pc + 1;
        register_write_addr = instruction[8:6]; // op0
        /*pass values to ALU*/
        case (instruction[15:9])
            `SHIFTR:
                register_data_in = registers[instruction[8:6]] >> instruction[5:0];
            `SHIFTRA:
                register_data_in = registers[instruction[8:6]] >>> instruction[5:0];
            `SHIFTL:
                register_data_in = registers[instruction[8:6]] << instruction[5:0];
        endcase
    end else if (instruction[15:14] == `MEM) begin
        pc_next = pc + 1;
        if (instruction[15:11] == `LOAD) begin
            /*assign ram addres*/
            address = registers[instruction[2:0]];
            /*set register write addres*/
            register_write_addr = instruction[10:8];
            /*enable reading from ram*/
            read = 1'b1;
            /*write value from ram*/
            register_data_in = data_in;
        end else if (instruction[15:11] == `LOADC) begin
            register_write_addr = instruction[10:8];
            register_data_in = {registers[instruction[10:8]][`D_SIZE-1:8], instruction[7:0]};
        end else if (instruction[15:11] == `STORE) begin
            /*assign ram address*/
            address = registers[instruction[10:8]];
            /*enable writing to ram*/
            write = 1'b1;
            /*write value to ram*/
            data_out = registers[instruction[2:0]];
        end
    end else if (instruction[15:14] == `COND) begin
        case (instruction[15:12])
            `JMP: begin
                pc_next = registers[instruction[2:0]][`A_SIZE:0];
             end
            `JMPR: begin
                pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
             end
             `JMPcond: begin
                case (instruction[11:9])
                   `N: begin
                        if (registers[instruction[8:6]][`D_SIZE-1] == 1'b1) begin
                            pc_next = registers[instruction[2:0]][`A_SIZE-1:0];
                        end else pc_next = pc + 1;
                    end
                    `NN: begin
                        if (registers[instruction[8:6]][`D_SIZE-1] == 1'b0) begin
                            pc_next = registers[instruction[2:0]][`A_SIZE-1:0];
                        end else pc_next = pc + 1;
                    end
                    `Z: begin
                        if (registers[instruction[8:6]] == `D_SIZE'd0) begin
                            pc_next = registers[instruction[2:0]][`A_SIZE-1:0];
                        end else pc_next = pc + 1;
                    end
                    `NZ: begin
                        if (registers[instruction[8:6]] != `D_SIZE'd0) begin
                            pc_next = registers[instruction[2:0]][`A_SIZE-1:0];
                        end else pc_next = pc + 1;
                    end
                endcase
             end
             `JMPRcond: begin
                case (instruction[11:9])
                   `N: begin
                        if (registers[instruction[8:6]][`D_SIZE-1] == 1'b1) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end else pc_next = pc + 1;
                    end
                    `NN: begin
                        if (registers[instruction[8:6]][`D_SIZE-1] == 1'b0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end else pc_next = pc + 1;
                    end
                    `Z: begin
                        if (registers[instruction[8:6]] == `D_SIZE'd0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end else pc_next = pc + 1;
                    end
                    `NZ: begin
                        if (registers[instruction[8:6]] != `D_SIZE'd0) begin
                            pc_next = pc + ({{`A_SIZE-6{instruction[5]}},instruction[5:0]});
                        end else pc_next = pc + 1;
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
    if(rst == 1'b1) begin
        pc <= pc_next;
        if(instruction[15:14] == `ARITHMETIC || instruction[15:14] == `SHIFT || instruction[15:14] == `MEM) begin
            registers[register_write_addr] = register_data_in;
        end
    end else begin
        for (idx = 0; idx < `R_NUM; idx = idx + 1) begin
            registers[idx] <= 0;
        end
        pc <= 0;
        pc_next <= 0;
        read <= 0;
        write <= 0;
        data_out <= 0;
        address <='bx;
    end
end

endmodule
