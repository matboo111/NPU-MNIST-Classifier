module input_buffer (
    input  wire       CLKEXT,
    input  wire       CLR_BUF_IN,
    input  wire       EN_BUF_IN,
    input  wire [7:0] DA,
    input  wire [7:0] DB,
    input  wire [7:0] DC,
    input  wire [7:0] DD,
    output wire [7:0] DA_OUT,
    output wire [7:0] DB_OUT,
    output wire [7:0] DC_OUT,
    output wire [7:0] DD_OUT
);

    wire [31:0] data_in;

    assign data_in = EN_BUF_IN ? {DA, DB, DC, DD} : 32'b0;

    ffd  #(
        .WIDTH(8)
    ) uut1 (
        .clk(CLKEXT),
        .rst(CLR_BUF_IN),
        .d(data_in[31:24]),
        .q(DA_OUT)
    );


    ffd #(
        .WIDTH(8)
    ) uut2 (
        .clk(CLKEXT),
        .rst(CLR_BUF_IN),
        .d(data_in[23:16]),
        .q(DB_OUT)
    );


    ffd #(
        .WIDTH(8)
    ) uut3 (
        .clk(CLKEXT),
        .rst(CLR_BUF_IN),
        .d(data_in[15:8]),
        .q(DC_OUT)
    );


    ffd #(
        .WIDTH(8)
    ) uut4 (
        .clk(CLKEXT),
        .rst(CLR_BUF_IN),
        .d(data_in[7:0]),
        .q(DD_OUT)
    );

endmodule