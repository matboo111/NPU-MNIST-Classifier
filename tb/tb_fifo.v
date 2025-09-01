`timescale 1ns/1ps

module tb_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8; 

    reg CLKEXT, RST, WR_EN, RD_EN;
    reg [DATA_WIDTH-1:0] DATA_IN;
    wire [DATA_WIDTH-1:0] DATA_OUT;
    wire FULL, EMPTY;

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .CLKEXT(CLKEXT),
        .RST(RST),
        .WR_EN(WR_EN),
        .RD_EN(RD_EN),
        .DATA_IN(DATA_IN),
        .DATA_OUT(DATA_OUT),
        .FULL(FULL),
        .EMPTY(EMPTY)
    );

    // Clock generation
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    integer i;

    initial begin
        // Inicialização
        RST = 1; WR_EN = 0; RD_EN = 0; DATA_IN = 0;
        #12;
        RST = 0;

        // Escreve até encher
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge CLKEXT);
            WR_EN = 1; RD_EN = 0; DATA_IN = i + 8'hA0;
        end
        @(negedge CLKEXT);
        WR_EN = 0;

        // Tenta escrever com FIFO cheia
        @(negedge CLKEXT);
        WR_EN = 1; DATA_IN = 8'hFF;
        @(negedge CLKEXT);
        WR_EN = 0;

        // Lê todos os dados
        for (i = 0; i < DEPTH; i = i + 1) begin
            @(negedge CLKEXT);
            WR_EN = 0; RD_EN = 1;
        end
        @(negedge CLKEXT);
        RD_EN = 0;

        // Tenta ler com FIFO vazia
        @(negedge CLKEXT);
        RD_EN = 1;
        @(negedge CLKEXT);
        RD_EN = 0;

        // Reset durante operação
        @(negedge CLKEXT);
        RST = 1;
        @(negedge CLKEXT);
        RST = 0;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b WR_EN=%b RD_EN=%b DATA_IN=%h | DATA_OUT=%h FULL=%b EMPTY=%b", 
            $time, RST, WR_EN, RD_EN, DATA_IN, DATA_OUT, FULL, EMPTY);
    end

endmodule