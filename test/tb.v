`default_nettype none
`timescale 1ns / 1ps
/* This testbench instantiates the top-level module 'tt_um_yourname_simplecache' and sets up signals
   for simulation with convenience signals for cocotb or other simulators.
*/

module tb ();
  // Dump the signals to a VCD file. You can view it with gtkwave or similar.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Testbench signals
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate your top-level module here
  tt_um_cache_controller user_project (
    // Include power ports for Gate Level simulation if enabled
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in  (ui_in),    // 8-bit input bus
    .uo_out (uo_out),   // 8-bit output bus
    .uio_in (uio_in),   // 8-bit bidir input
    .uio_out(uio_out),  // 8-bit bidir output
    .uio_oe (uio_oe),   // 8-bit bidir enable
    .ena    (ena),      // enable input
    .clk    (clk),      // clock input
    .rst_n  (rst_n)     // active low reset
  );

endmodule
