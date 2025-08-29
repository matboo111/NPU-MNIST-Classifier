module m16_bit(
    input wire [15:0] a,
    input wire [15:0] b,
    output wire [15:0] ADD_OUT
);

    wire [16:0] A,B,OUT;
    assign A = {a[15], a};
    assign B = {b[15], b};
    assign OUT = A + B;

    mux #(
        .WIDTH(16),
        .SEL_WIDTH(2)
    ) mux_inst (
        .data_in_flat({OUT[15:0],16'h8000,16'h7FFF,OUT[15:0]}),
        .sel({OUT[16],OUT[15]}),                    // Se o bit de sinal for 0, seleciona os 16 bits menos significativos; se for 1, seleciona os 16 bits mais significativos
        .data_out(ADD_OUT)
    );

endmodule