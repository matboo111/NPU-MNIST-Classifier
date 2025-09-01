`timescale 1ns/1ps

module tb_npu_core;

    reg        CLKEXT;
    reg        RST;
    reg [7:0]  DA, DB, DC, DD;
    reg [15:0] SSFR, CON_SIG;
    reg        SHIFT_DEB, EN_PISO_DEB, CLR_PISO_DEB;
    reg        RD_EN;
    wire [7:0] DATA_OUT;

    npu_core uut (
        .CLKEXT(CLKEXT),
        .RST(RST),
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
        .DATA_OUT(DATA_OUT)
    );

    // Clock generation
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    initial begin
        // Inicialização
        RST = 1;
        DA = 8'd0; DB = 8'd0; DC = 8'd0; DD = 8'd0;
        SSFR = 16'h0000;
        CON_SIG = 16'h0000;
        SHIFT_DEB = 0;
        EN_PISO_DEB = 0;
        CLR_PISO_DEB = 0;
        RD_EN = 0;
        #20;
        RST = 0;

        // 1. Carrega dados e ativa buffer de entrada
        CON_SIG[15] = 1; // EN_BUF_IN
        DA = 8'd10; DB = 8'd20; DC = 8'd30; DD = 8'd40;
        #10;
        CON_SIG[15] = 0; // Desativa buffer após carregamento

        // 2. Ativa MACs e faz operação de multiplicação e acumulação
        CON_SIG[13] = 1; // EN_MAC
        #20;
        CON_SIG[13] = 0;

        // 3. Ativa reLU (sem bypass)
        CON_SIG[11] = 1; // EN_reLU
        SSFR[12] = 0;    // BYPASS_reLU1
        SSFR[11] = 0;    // BYPASS_reLU2
        #20;
        CON_SIG[11] = 0;

        // 4. Ativa auto_comparator
        SSFR[10] = 1; // EN_COMP
        #10;
        SSFR[10] = 0;

        // 5. Seleciona saída do maior valor (LARGEST[7:0])
        SSFR[15:13] = 3'b011; // SEL_OUT = 3 (ajuste conforme ordem do mux)
        #10;

        // 6. Seleciona saída do índice do maior valor
        SSFR[15:13] = 3'b010; // SEL_OUT = 2 (ajuste conforme ordem do mux)
        #10;

        // 7. Seleciona saída do PISO_DEB
        SSFR[15:13] = 3'b100; // SEL_OUT = 4 (ajuste conforme ordem do mux)
        EN_PISO_DEB = 1;
        SHIFT_DEB = 1;
        #10;
        SHIFT_DEB = 0;
        EN_PISO_DEB = 0;

        // 8. Seleciona saída do PISO_OUT (reLU outputs)
        SSFR[15:13] = 3'b001; // SEL_OUT = 1 (ajuste conforme ordem do mux)
        CON_SIG[10] = 1; // SHIFT_OUT
        CON_SIG[9]  = 1; // EN_PISO_OUT
        #10;
        CON_SIG[10] = 0;
        CON_SIG[9]  = 0;

        // 9. Escreve na FIFO
        SSFR[15:13] = 3'b000; // SEL_OUT = 0 (ajuste conforme ordem do mux)
        CON_SIG[7] = 1; // WR_EN
        #10;
        CON_SIG[7] = 0;

        // 10. Lê da FIFO
        RD_EN = 1;
        #10;
        RD_EN = 0;

        // 11. Reset global e repete operação com outros dados
        RST = 1; #10; RST = 0; #10;
        DA = 8'd5; DB = 8'd2; DC = 8'd8; DD = 8'd3;
        CON_SIG[15] = 1; #10; CON_SIG[15] = 0;
        CON_SIG[13] = 1; #20; CON_SIG[13] = 0;
        CON_SIG[11] = 1; #20; CON_SIG[11] = 0;
        SSFR[10] = 1; #10; SSFR[10] = 0;
        CON_SIG[7] = 1; #10; CON_SIG[7] = 0;
        RD_EN = 1; #10; RD_EN = 0;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b DA=%d DB=%d DC=%d DD=%d | DATA_OUT=%h | SSFR=%h CON_SIG=%h RD_EN=%b", 
            $time, RST, DA, DB, DC, DD, DATA_OUT, SSFR, CON_SIG, RD_EN);
    end

endmodule