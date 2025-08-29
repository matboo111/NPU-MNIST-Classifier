module mac (
    input wire CLKEXT,
    input wire RST_MAC,
    input wire EN_MAC,
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [7:0] BIAS_IN,
    output reg [15:0] result,
);

    wire [15:0] out_mult, out_16bit, out_mux;
    wire [7:0] A, B;

    assign A = EN_MAC ? a : 8'b0;
    assign B = EN_MAC ? b : 8'b0;

    assign out_mult = A * B;

    m16_bit_adder adder_inst (
        .A(out_mult),
        .B(result),
        .S(out_16bit)
    );

    mux #(
        .WIDTH(16),
        .SEL_WIDTH(1)
    ) mux_inst (
        .data_in_flat({BIAS_IN,out_16bit}),
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