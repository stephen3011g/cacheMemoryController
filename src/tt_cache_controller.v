// Simple direct-mapped cache controller core
module simple_cache_controller(
    input         clk,
    input         rst_n,
    input  [7:0]  cpu_addr,      // 8-bit CPU address
    input  [31:0] cpu_din,       // CPU write data
    output reg [31:0] cpu_dout,  // CPU read data
    input         cpu_rw,        // 0=read, 1=write
    input         cpu_valid,     // CPU request valid
    output reg    cache_ready
);

    // Cache specs: 4 blocks, each with 32-bit data, 6 bit tag, valid and dirty bits
    reg [31:0] data_mem [3:0];
    reg [5:0]  tag_mem  [3:0];
    reg        valid_mem[3:0];
    reg        dirty_mem[3:0];

    wire [1:0] index = cpu_addr[3:2];  // 2 bits index for 4 entries
    wire [5:0] tag   = cpu_addr[7:2];  // 6 bits tag

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cpu_dout    <= 0;
            cache_ready <= 1;
            valid_mem[0] <= 0; valid_mem[1] <= 0;
            valid_mem[2] <= 0; valid_mem[3] <= 0;
            dirty_mem[0] <= 0; dirty_mem[1] <= 0;
            dirty_mem[2] <= 0; dirty_mem[3] <= 0;
            tag_mem[0]   <= 0; tag_mem[1]   <= 0;
            tag_mem[2]   <= 0; tag_mem[3]   <= 0;
            data_mem[0]  <= 0; data_mem[1]  <= 0;
            data_mem[2]  <= 0; data_mem[3]  <= 0;
        end else if (cpu_valid && cache_ready) begin
            if (valid_mem[index] && tag_mem[index] == tag) begin
                // Cache hit
                if (cpu_rw) begin
                    data_mem[index] <= cpu_din;
                    dirty_mem[index] <= 1;
                end else begin
                    cpu_dout <= data_mem[index];
                end
            end else begin
                // Cache miss: refill and update
                if (cpu_rw) begin
                    data_mem[index] <= cpu_din;
                    tag_mem[index]  <= tag;
                    valid_mem[index] <= 1;
                    dirty_mem[index] <= 1;
                end else begin
                    data_mem[index] <= 32'hDEADBEEF; // Placeholder for main memory data
                    tag_mem[index]  <= tag;
                    valid_mem[index] <= 1;
                    dirty_mem[index] <= 0;
                    cpu_dout <= 32'hDEADBEEF;
                end
            end
        end
    end
endmodule


// Top-level module adapted for SkyWater Tiny Tapeout pins
module tt_cache_controller(
    input         clk,
    input         rst_n,
    input  [7:0]  ui_in,    // 8 digital inputs
    output [7:0]  uo_out,   // 8 digital outputs
    inout  [7:0]  uio       // 8 bidirectional pins (unused here)
);

    // Use ui_in as cpu_addr plus rw control in MSB
    wire [7:0] cpu_addr = ui_in;
    wire       cpu_rw   = ui_in[7];       // MSB as read/write
    wire       cpu_valid = 1'b1;          // always valid for simplicity

    // Use fixed write data since input pins limited
    wire [31:0] cpu_din = 32'hCAFEBABE;

    wire [31:0] cpu_dout;
    wire cache_ready;

    // Instantiate cache core
    simple_cache_controller cache (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_addr(cpu_addr),
        .cpu_din(cpu_din),
        .cpu_dout(cpu_dout),
        .cpu_rw(cpu_rw),
        .cpu_valid(cpu_valid),
        .cache_ready(cache_ready)
    );

    // Output lower 8 bits of cpu_dout to uo_out
    assign uo_out = cpu_dout[7:0];

    // Tie off unused bidir signals
    wire [7:0] unused_uio;
    assign unused_uio = uio;

endmodule
