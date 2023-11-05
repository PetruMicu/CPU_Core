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
    input 		rst,   // active 0
    input		clk,
    // program memory
    output [`A_SIZE-1:0] pc,
    input        [15:0] instruction,
    // data memory
    output 		read,  // active 1
    output 		write, // active 1
    output [`A_SIZE-1:0]	address,
    input  [`D_SIZE-1:0]	data_in,
    output [`D_SIZE-1:0]	data_out
);
endmodule
