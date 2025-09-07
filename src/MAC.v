module mac (
    input  wire       CLKEXT,
    input  wire       RST_MAC,
    input  wire       EN_MAC,
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [7:0] BIAS_IN,
    output wire [15:0] result
);

    wire signed [15:0] out_mult, out_16bit, out_mux;
    wire signed [7:0] A, B;

    assign A = EN_MAC ? $signed(a) : 8'b0;
    assign B = EN_MAC ? $signed(b) : 8'b0;

    assign out_mult = A * B;

    m16_bit adder_inst (
        .a(out_mult),
        .b(result),
        .ADD_OUT(out_16bit)
    );

    mux #(
        .WIDTH(16),
        .SEL_WIDTH(1)
    ) mux_inst (
        .data_in_flat({{8'b0,BIAS_IN},out_16bit}),
        .sel(RST_MAC),
        .data_out(out_mux)
    );

    ffd #(16) ffd_inst (
        .clk(CLKEXT),
        .rst(RST_MAC),
        .d(out_mux),
        .q(result)
    );

endmodule