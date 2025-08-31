`timescale 1ns/1ps

module tb_reLU;

    reg CLKEXT;
    reg RST;
    reg [15:0] DATA_IN;
    reg EN_reLU;
    reg BYPASS_reLU;
    wire [15:0] reLU_OUT;

    // Instancia o módulo reLU
    reLU uut (
        .CLKEXT(CLKEXT),
        .RST(RST),
        .DATA_IN(DATA_IN),
        .EN_reLU(EN_reLU),
        .BYPASS_reLU(BYPASS_reLU),
        .reLU_OUT(reLU_OUT)
    );

    // Geração do clock
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT; // Clock de 10ns

    initial begin
        // Inicialização
        RST = 1;
        EN_reLU = 0;
        BYPASS_reLU = 0;
        DATA_IN = 16'd0;

        #12; // Espera um pouco e tira do reset
        RST = 0;

        // Teste 1: Valor positivo, EN_reLU ativo, BYPASS_reLU desativado
        EN_reLU = 1;
        DATA_IN = 16'd1234;
        BYPASS_reLU = 0;
        #10;

        // Teste 2: Valor negativo, EN_reLU ativo, BYPASS_reLU desativado
        DATA_IN = 16'hFFFF; // -1 em complemento de dois
        #10;

        // Teste 3: Valor negativo, EN_reLU ativo, BYPASS_reLU ativado (deve passar o valor negativo)
        BYPASS_reLU = 1;
        #10;

        // Teste 4: Valor positivo, EN_reLU desativado (saída deve ser zero)
        EN_reLU = 0;
        DATA_IN = 16'd5678;
        BYPASS_reLU = 0;
        #10;

        // Teste 5: Reset durante operação
        RST = 1;
        #10;
        RST = 0;
        EN_reLU = 1;
        DATA_IN = 16'd4321;
        #10;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b EN_reLU=%b BYPASS_reLU=%b DATA_IN=%d (0x%h) reLU_OUT=%d (0x%h)", 
            $time, RST, EN_reLU, BYPASS_reLU, DATA_IN, DATA_IN, reLU_OUT, reLU_OUT);
    end

endmodule