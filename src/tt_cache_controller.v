module simple_cache_controller(
    input         clk,
    input         rst_n,
    input  [6:0]  cpu_addr,      // 7-bit CPU address (exclude MSB read/write bit)
    input  [31:0] cpu_din,
    output reg [31:0] cpu_dout,
    input         cpu_rw,
    input         cpu_valid,
    output reg    cache_ready
);

    reg [31:0] data_mem [3:0];
    reg [5:0]  tag_mem  [3:0];
    reg        valid_mem[3:0];
    reg        dirty_mem[3:0];

    wire [1:0] index = cpu_addr[3:2];
    wire [5:0] tag   = cpu_addr[6:2];

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
                if (cpu_rw) begin
                    data_mem[index] <= cpu_din;
                    dirty_mem[index] <= 1;
                end else begin
                    cpu_dout <= data_mem[index];
                end
            end else begin
                if (cpu_rw) begin
                    data_mem[index] <= cpu_din;
                    tag_mem[index]  <= tag;
                    valid_mem[index] <= 1;
                    dirty_mem[index] <= 1;
                end else begin
                    data_mem[index] <= 32'hDEADBEEF;
                    tag_mem[index]  <= tag;
                    valid_mem[index] <= 1;
                    dirty_mem[index] <= 0;
                    cpu_dout <= 32'hDEADBEEF;
                end
            end
        end
    end
endmodule
module tt_um_cache_controller(
    input         clk,
    input         rst_n,
    input         ena,
    input  [7:0]  ui_in,    // 8-bit input: [7] = read/write, [6:0] = address
    output [7:0]  uo_out,
    inout  [7:0]  uio
);

    wire        cpu_rw   = ui_in[7];
    wire [6:0]  cpu_addr = ui_in[6:0];
    wire        cpu_valid = ena;

    wire [31:0] cpu_din = 32'hCAFEBABE;
    wire [31:0] cpu_dout;
    wire cache_ready;

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

    assign uo_out = cpu_dout[7:0];
    wire [7:0] unused_uio = uio; // Unused bidirectional pins

endmodule

