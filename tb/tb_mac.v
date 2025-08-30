`timescale 1ns/1ps

module tb_mac;

    reg CLKEXT;
    reg RST_MAC;
    reg EN_MAC;
    reg [7:0] a, b;
    wire [15:0] result;

    // Instancia o módulo MAC
    mac uut (
        .CLKEXT(CLKEXT),
        .RST_MAC(RST_MAC),
        .EN_MAC(EN_MAC),
        .a(a),
        .b(b),
        .BIAS_IN(a),
        .result(result)
    );

    // Geração do clock
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT; // Clock de 10ns

    initial begin
        // Inicialização
        RST_MAC = 1;
        EN_MAC = 0;
        a = 0;
        b = 0;
        //BIAS_IN = 0;

        // Reset
        #12;
        RST_MAC = 0;

        // Teste 1: Multiplicação e acumulação simples
        EN_MAC = 1;
        a = 8'd3;
        b = 8'd4;
        //BIAS_IN = 8'd10;
        #10;

        // Teste 2: Novo valor de entrada
        a = 8'd2;
        b = 8'd5;
        #10;

        // Teste 3: Desabilita EN_MAC (resultado não deve mudar)
        EN_MAC = 0;
        #10;

        // Teste 4: Reset MAC (resultado deve ir para BIAS_IN)
        RST_MAC = 1;
        #10;
        RST_MAC = 0;
        EN_MAC = 1;
        a = 8'd1;
        b = 8'd7;
        #10;

        // Fim do teste
        $finish;
    end

    initial begin
        $monitor("T=%0t | RST_MAC=%b EN_MAC=%b a=%d b=%d result=%d", $time, RST_MAC, EN_MAC, a, b, result);
    end

endmodule