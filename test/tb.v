`default_nettype none
`timescale 1ns / 1ps

module tb ();

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  wire [7:0] uo_out;
  wire [7:0] uio;

  initial clk = 0;
  always #5 clk = ~clk;

  tt_um_cache_controller dut (
    .clk(clk),
    .rst_n(rst_n),
    .ena(ena),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio(uio)
  );

  initial begin
    rst_n = 0; ena = 0; ui_in = 0;
    #20; rst_n = 1; ena = 1;
    #10;

    ui_in = 8'b10000100; // Write flag and address 0x04
    #20;

    ui_in = 8'b00000100; // Read from 0x04
    #20;

    ui_in = 8'b00001000; // Read from 0x08 (miss)
    #20;

    $finish;
  end

  initial begin
    $monitor("Time=%0t clk=%b rst_n=%b ena=%b ui_in=%b uo_out=%h", $time, clk, rst_n, ena, ui_in, uo_out);
  end

endmodule
