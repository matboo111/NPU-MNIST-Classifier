module npu_top(
    input  wire        CLKEXT,
    input  wire        RST_GLO,
    input  wire        EN_FSM,
    input  wire        EN_CONFIG,
    input  wire [7:0]  DA,
    input  wire [7:0]  DB,
    input  wire [7:0]  DC,
    input  wire [7:0]  DD,
    input  wire        RD_EN,
    input  wire        EN_PISO_DEB,
    input  wire        CLR_PISO_DEB,
    input  wire        SHIFT_DEB,
    input  wire        SEL_CON,
    output wire [7:0]  D_OUT,
    output wire        FULL,
    output wire        EMPTY
);

    wire [15:0] SSFR;
    wire [15:0] CON_SIG;
    wire [15:0] CON_SIG_FSM;

    ssfr ssfr_inst (
        .CLKEXT(CLKEXT),
        .RST(RST_GLO),
        .DA(DA),
        .DB(DB),
        .EN_CONFIG(EN_CONFIG),
        .SSFR(SSFR)
    );

    fsm fsm_inst (
        .CLKEXT(CLKEXT),
        .RST(RST_GLO),
        .EN_FSM(EN_FSM),
        .DB(DB),
        .DD(DD),
        .CON_SIG(CON_SIG_FSM)
    );

    mux #(
        .WIDTH(16),
        .SEL_WIDTH(1)
    ) mux_top (
        .data_in_flat({CON_SIG_FSM,{DC,CON_SIG_FSM[7],7'b0000000}}),
        .sel(SEL_CON),
        .data_out(CON_SIG)
    );

    npu_core npu_core_inst (
        .CLKEXT(CLKEXT),
        .RST(RST_GLO),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .RD_EN(RD_EN),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .SHIFT_DEB(SHIFT_DEB),
        .EN_PISO_DEB(EN_PISO_DEB),
        .CLR_PISO_DEB(CLR_PISO_DEB),
        .DATA_OUT(D_OUT),
        .FULL(FULL),
        .EMPTY(EMPTY)
    );

endmodule