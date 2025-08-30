module mux #(
    parameter WIDTH,
    parameter SEL_WIDTH
)(
    input  wire [WIDTH*(1<<SEL_WIDTH)-1:0] data_in_flat,
    input  wire [SEL_WIDTH-1:0] sel,
    output wire [WIDTH-1:0] data_out
);

    wire [WIDTH-1:0] data_in [0:(1<<SEL_WIDTH)-1];

    
    genvar i;
    generate
        for (i = 0; i < (1<<SEL_WIDTH); i = i + 1) begin : UNPACK
            assign data_in[i] = data_in_flat[WIDTH*i +: WIDTH];
        end
    endgenerate

    assign data_out = data_in[sel];

endmodule