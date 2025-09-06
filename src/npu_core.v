module npu_core (
    input  wire        CLKEXT,
    input  wire        RST,
    input  wire [7:0]  DA,
    input  wire [7:0]  DB,
    input  wire [7:0]  DC,
    input  wire [7:0]  DD,
    input  wire        RD_EN,
    input  wire [15:0] SSFR,
    input  wire [15:0] CON_SIG,
    input  wire        SHIFT_DEB,
    input  wire        EN_PISO_DEB,
    input  wire        CLR_PISO_DEB,
    output wire [7:0]  DATA_OUT,
    output wire        FULL,
    output wire        EMPTY
);

    wire [7:0] DA_OUT;
    wire [7:0] DB_OUT;
    wire [7:0] DC_OUT;
    wire [7:0] DD_OUT;
 //------------- CON_SIG SIGNALS --------------
    wire EN_BUF_IN;
    wire CLR_BUF_IN;
    wire EN_MAC;
    wire RST_MAC;
    wire EN_reLU;
    wire SHIFT_OUT;
    wire EN_PISO_OUT;
    wire CLR_PISO_OUT;
    wire WR_EN;
//------------- SSFR SIGNALS ------------------

    wire [2:0] SEL_OUT;
    wire       BYPASS_reLU1;
    wire       BYPASS_reLU2;
    wire       EN_COMP;
    wire       RST_COMP;
    wire       EN_FIFO;
    wire       RST_FIFO;

//------------- INTERNAL SIGNALS --------------
    wire [15:0] RESULT_MAC1;
    wire [15:0] RESULT_MAC2;

    wire [7:0] DATA_OUT_PISO_DEB;

    wire [15:0] reLU_OUT1;
    wire [15:0] reLU_OUT2;

    wire [7:0] DATA_OUT_PISO_OUT;

    wire [7:0] DATA_OUT_FIFO;

    wire [15:0] LARGEST;
    wire [7:0]  INDEX;

    wire CLR_PISO_OUT_RST;
    wire RST_COMP_RST;
    wire CLR_PISO_DEB_RST;
    wire RST_MAC_RST;
    wire CLR_BUF_IN_RST;

    wire WR_EN_FIFO;
    wire RD_EN_FIFO;
//------------- ASSIGNMENTS -------------------
    assign EN_BUF_IN      = CON_SIG[15];
    assign CLR_BUF_IN     = CON_SIG[14];
    assign EN_MAC         = CON_SIG[13];
    assign RST_MAC        = CON_SIG[12];
    assign EN_reLU        = CON_SIG[11];
    assign SHIFT_OUT      = CON_SIG[10];
    assign EN_PISO_OUT    = CON_SIG[9];
    assign CLR_PISO_OUT   = CON_SIG[8];
    assign WR_EN          = CON_SIG[7];

    assign SEL_OUT        = SSFR[15:13];
    assign BYPASS_reLU1    = SSFR[12];
    assign BYPASS_reLU2    = SSFR[11];
    assign EN_COMP        = SSFR[10];
    assign RST_COMP       = SSFR[9];
    assign EN_FIFO        = SSFR[8];
    assign RST_FIFO       = SSFR[7];

    assign CLR_PISO_OUT_RST = CLR_PISO_OUT | RST;
    assign RST_COMP_RST     = RST_COMP     | RST;
    assign CLR_PISO_DEB_RST = CLR_PISO_DEB | RST;
    assign RST_MAC_RST      = RST_MAC      | RST;
    assign CLR_BUF_IN_RST   = CLR_BUF_IN   | RST;

    assign RD_EN_FIFO = RD_EN & !EMPTY;
    assign WR_EN_FIFO = WR_EN & !FULL;


    input_buffer  BUFFER (
            .CLKEXT(CLKEXT),
            .CLR_BUF_IN(CLR_BUF_IN_RST),
            .EN_BUF_IN(EN_BUF_IN),
            .DA(DA),
            .DB(DB),
            .DC(DC),
            .DD(DD),
            .DA_OUT(DA_OUT),
            .DB_OUT(DB_OUT),
            .DC_OUT(DC_OUT),
            .DD_OUT(DD_OUT)
    );

    mac MAC1 (
            .CLKEXT(CLKEXT),
            .RST_MAC(RST_MAC_RST),
            .EN_MAC(EN_MAC),
            .a(DA_OUT),
            .b(DB_OUT),
            .BIAS_IN(DA_OUT),
            .result(RESULT_MAC1)
        );

    mac MAC2 (
            .CLKEXT(CLKEXT),
            .RST_MAC(RST_MAC_RST),
            .EN_MAC(EN_MAC),
            .a(DC_OUT),
            .b(DD_OUT),
            .BIAS_IN(DC_OUT),
            .result(RESULT_MAC2)
        );

    PISO #(
            .WIDTH(8),
            .NUM_TAPS(12)
    ) PISO_DEB (
            .CLR_PISO_OUT(CLR_PISO_DEB_RST),
            .CLKEXT(CLKEXT),
            .SHIFT_OUT(SHIFT_DEB),
            .EN_PISO_OUT(EN_PISO_DEB),
            .DATA_IN({SSFR[15:8], SSFR[7:0], CON_SIG[15:8], CON_SIG[7:0], RESULT_MAC2[15:8], RESULT_MAC2[7:0], RESULT_MAC1[15:8], RESULT_MAC1[7:0], DD_OUT, DC_OUT, DB_OUT, DA_OUT}),
            .DATA_OUT(DATA_OUT_PISO_DEB)
        );

    reLU reLU1 (
            .CLKEXT(CLKEXT),
            .RST(RST),
            .DATA_IN(RESULT_MAC1),
            .EN_reLU(EN_reLU),
            .BYPASS_reLU(BYPASS_reLU),
            .reLU_OUT(reLU_OUT1)
        );

    reLU reLU2 (
            .CLKEXT(CLKEXT),
            .RST(RST),
            .DATA_IN(RESULT_MAC2),
            .EN_reLU(EN_reLU),
            .BYPASS_reLU(BYPASS_reLU),
            .reLU_OUT(reLU_OUT2)
        );

    auto_comparator COMP (
            .CLKEXT(CLKEXT),
            .RST_COMP(RST_COMP_RST),
            .EN_COMP(EN_COMP),
            .TRIG(EN_reLU),
            .IN1(reLU_OUT1),
            .IN2(reLU_OUT2),
            .LARGEST(LARGEST),
            .INDEX(INDEX)
        );

    PISO #(
            .WIDTH(8),
            .NUM_TAPS(4)
    ) PISO_OUT (
            .CLR_PISO_OUT(CLR_PISO_OUT_RST),
            .CLKEXT(CLKEXT),
            .SHIFT_OUT(SHIFT_OUT),
            .EN_PISO_OUT(EN_PISO_OUT),
            .DATA_IN({reLU_OUT2[15:8], reLU_OUT2[7:0], reLU_OUT1[15:8], reLU_OUT1[7:0]}),
            .DATA_OUT(DATA_OUT_PISO_OUT)
        );

    fifo #(
            .DATA_WIDTH(8),
            .DEPTH(128)
    ) FIFO_OUT (
            .CLKEXT(CLKEXT),
            .RST(RST),
            .WR_EN(WR_EN_FIFO),
            .RD_EN(RD_EN_FIFO),
            .DATA_IN(DATA_OUT_PISO_OUT),
            .DATA_OUT(DATA_OUT_FIFO),
            .FULL(FULL),
            .EMPTY(EMPTY)
        );

    mux #(
            .WIDTH(8),
            .SEL_WIDTH(3)
        ) mux_inst (
            .data_in_flat({8'b0,8'b0,DATA_OUT_PISO_DEB,LARGEST[7:0],LARGEST[15:8],INDEX,DATA_OUT_PISO_OUT,DATA_OUT_FIFO}),
            .sel(SEL_OUT),                    // Se o bit de sinal for 0, seleciona os 16 bits menos significativos; se for 1, seleciona os 16 bits mais significativos
            .data_out(DATA_OUT)
        );


endmodule