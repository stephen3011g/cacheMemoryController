`timescale 1ns / 1ps
`default_nettype none

module tb();

  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  wire [7:0] uo_out;
  wire [7:0] uio;

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
      .uio(uio)
  );

  initial begin
    rst_n = 0;
    ena = 0;
    ui_in = 8'b0;
    #20;
    rst_n = 1;
    ena = 1;
    #10;

    ui_in = 8'b10000100; // Write (1) to address 0x04
    #40;

    ui_in = 8'b00000100; // Read (0) from address 0x04 (same as write)
    #40;

    ui_in = 8'b00001000; // Read (0) from address 0x08 (miss case)
    #40;
  end

  initial begin
    $monitor("Time=%0t clk=%b rst_n=%b ena=%b ui_in=%b uo_out=%h", $time, clk, rst_n, ena, ui_in, uo_out);
  end

endmodule
