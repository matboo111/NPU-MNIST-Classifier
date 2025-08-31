`timescale 1ns/1ps

module tb_auto_comparator;

    reg        CLKEXT;
    reg        RST_COMP;
    reg        EN_COMP;
    reg        TRIG;
    reg [15:0] IN1, IN2;
    wire [15:0] LARGEST;
    wire [7:0]  INDEX;

    auto_comparator uut (
        .CLKEXT(CLKEXT),
        .RST_COMP(RST_COMP),
        .EN_COMP(EN_COMP),
        .TRIG(TRIG),
        .IN1(IN1),
        .IN2(IN2),
        .LARGEST(LARGEST),
        .INDEX(INDEX)
    );

    // Clock generation
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    initial begin
        // Inicialização
        RST_COMP = 1;
        EN_COMP  = 0;
        TRIG     = 0;
        IN1      = 16'h0000;
        IN2      = 16'h0000;
        #12;
        RST_COMP = 0;

        // Frame 1: EN_COMP=0, reset ativo, deve manter valores iniciais
        EN_COMP = 0; TRIG = 0; IN1 = 16'h0000; IN2 = 16'h0000; #10;

        // Frame 2: EN_COMP=1, compara 16'hFFF1 e 16'hFFF2
        EN_COMP = 1; TRIG = 1; IN1 = 16'hFFF1; IN2 = 16'hFFF2; #10;
        TRIG = 0; #10;

        // Frame 3: compara 16'hFFF4 e 16'hFFF3
        TRIG = 1; IN1 = 16'hFFF4; IN2 = 16'hFFF3; #10;
        TRIG = 0; #10;

        // Frame 4: compara 16'hFFFF e 16'hFFFF
        TRIG = 1; IN1 = 16'hFFFF; IN2 = 16'hFFFF; #10;
        TRIG = 0; #10;

        // Frame 5: compara 16'h0000 e 16'h0003
        TRIG = 1; IN1 = 16'h0000; IN2 = 16'h0003; #10;
        TRIG = 0; #10;

        // Frame 6: compara 16'h0001 e 16'h0002
        TRIG = 1; IN1 = 16'h0001; IN2 = 16'h0002; #10;
        TRIG = 0; #10;

        // Reset durante operação
        RST_COMP = 1; #10;
        RST_COMP = 0; #10;

        // Novo par após reset
        EN_COMP = 1; TRIG = 1; IN1 = 16'h1234; IN2 = 16'h5678; #10;
        TRIG = 0; #10;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b EN=%b TRIG=%b IN1=%h IN2=%h | LARGEST=%h INDEX=%d", 
            $time, RST_COMP, EN_COMP, TRIG, IN1, IN2, LARGEST, INDEX);
    end

endmodule