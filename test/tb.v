`timescale 1ns / 1ps
`default_nettype none

module tb();

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  wire [7:0] uo_out;
  reg [7:0] uio_in;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  initial clk = 0;
  always #5 clk = ~clk;

  tt_um_cache_controller dut (
      .clk(clk),
      .rst_n(rst_n),
      .ena(ena),
      .ui_in(ui_in),
      .uo_out(uo_out),
      .uio_in(uio_in),
      .uio_out(uio_out),
      .uio_oe(uio_oe)
  );

  initial begin
    rst_n = 0; ena = 0; ui_in = 0; uio_in = 0;
    #20;
    rst_n = 1; ena = 1;
    #10;

    ui_in = 8'b10000100; // Write flag and address 0x04
    #40;

    ui_in = 8'b00000100; // Read from address 0x04
    #40;

    ui_in = 8'b00001000; // Read from address 0x08 (miss)
    #40;

  end

  initial begin
    $monitor("Time=%0t clk=%b rst_n=%b ena=%b ui_in=%b uo_out=%h", $time, clk, rst_n, ena, ui_in, uo_out);
  end

endmodule
