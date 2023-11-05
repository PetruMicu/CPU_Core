`timescale 1ns / 1ps
`include "macros.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2023 12:27:05 AM
// Design Name: 
// Module Name: reg_module_tb
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


module reg_module_tb;

  // Signals
  reg rst;
  reg clk;
  reg write_enable;
  reg [`R_SIZE-1:0] write_addr;
  reg [`R_SIZE-1:0] read1_addr;
  reg [`R_SIZE-1:0] read2_addr;
  reg [`D_SIZE-1:0] data_in;
  wire [`D_SIZE-1:0] data1_out;
  wire [`D_SIZE-1:0] data2_out;

  // Instantiate the module under test
  reg_module reg_module_inst (
    .rst(rst),
    .clk(clk),
    .write_enable(write_enable),
    .write_addr(write_addr),
    .read1_addr(read1_addr),
    .read2_addr(read2_addr),
    .data_in(data_in),
    .data1_out(data1_out),
    .data2_out(data2_out)
  );

  // Clock generation
  always begin
    #5 clk = ~clk; // Toggle the clock every 5 time units
  end

  // Test case
  initial begin
    // Initialize signals
    rst = 0;
    clk = 0;
    write_enable = 0;
    write_addr = 0; // Address for writing
    read1_addr = 0; // Address for reading
    read2_addr = 1; // Another address for reading
    data_in = 8'hFF; // Data to write

    // Release reset
    #10 rst = 1;

    // Write data to the register
    #20 write_enable = 1;
    #10 write_addr = 1;
    #30 write_enable = 0;

    // Monitor the results
    $display("Data1_out = %h, Data2_out = %h", data1_out, data2_out);

    // End simulation
    #10 $finish;
  end

endmodule
