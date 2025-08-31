module reLU (
    input wire CLKEXT,
    input wire RST,
    input wire [15:0] DATA_IN,
    input wire EN_reLU,
    input wire BYPASS_reLU,
    output wire [15:0] reLU_OUT
);

    wire mux_sel;
    wire [15:0] data_in_ff,data_in_ff1;

    assign data_in_ff = EN_reLU ? data_in_ff1 : 16'b0; 
    assign mux_sel = DATA_IN[15] & ~BYPASS_reLU; // If DATA_IN is negative and BYPASS is not enabled, select zero
    
    mux #(
        .WIDTH(16),
        .SEL_WIDTH(1)
    ) mux_reLu (
        .data_in_flat({16'b0,DATA_IN}),
        .sel(mux_sel),
        .data_out(data_in_ff1)
    );

    ffd #(16) ffd_reLU (
        .clk(CLKEXT),
        .rst(RST),
        .d(data_in_ff),
        .q(reLU_OUT)
    );

endmodule