`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump signals for waveform viewing
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Testbench signals
  reg        clk;
  reg        rst_n;
  reg  [7:0] ui_in;
  wire [7:0] uo_out;
  wire [7:0] uio;

  // Clock generation: 10ns period
  initial clk = 0;
  always #5 clk = ~clk;

  // Instantiate your top-level module
  tt_um_cache_controller dut (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio(uio)
  );

  initial begin
    // Initialize inputs
    rst_n = 0;
    ui_in = 8'b0;
    #20;
    rst_n = 1;

    // Test writing to address 0x04 with MSB=1 (write)
    ui_in = 8'b10000100; // Write flag (MSB=1) + address 0x04
    #10;

    // Test reading from address 0x04 with MSB=0 (read)
    ui_in = 8'b00000100; // Read flag (MSB=0) + address 0x04
    #10;

    // Test reading from address 0x08 (miss)
    ui_in = 8'b00001000; // Read address 0x08
    #10;

    #20;
    $finish;
  end

  // Optional: monitor signals
  initial begin
    $monitor("Time=%0t clk=%b rst_n=%b ui_in=%b uo_out=%h uio=%h", 
              $time, clk, rst_n, ui_in, uo_out, uio);
  end

endmodule
