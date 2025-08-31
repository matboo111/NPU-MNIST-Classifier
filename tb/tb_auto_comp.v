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

    // Geração do clock
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    initial begin
        // Inicialização
        RST_COMP = 1;
        EN_COMP  = 0;
        TRIG     = 0;
        IN1      = 0;
        IN2      = 0;
        #12;
        RST_COMP = 0;

        // Ativa comparação
        EN_COMP = 1;

        // Par 1
        IN1 = 16'd100; IN2 = 16'd200; TRIG = 1; #10;
        TRIG = 0; #10;

        // Par 2
        IN1 = 16'd300; IN2 = 16'd150; TRIG = 1; #10;
        TRIG = 0; #10;

        // Par 3 (negativo e positivo)
        IN1 = 16'h8001; IN2 = 16'd400; TRIG = 1; #10;
        TRIG = 0; #10;

        // Par 4 (ambos negativos)
        IN1 = 16'h8002; IN2 = 16'h8003; TRIG = 1; #10;
        TRIG = 0; #10;

        // Reset durante operação
        RST_COMP = 1; #10;
        RST_COMP = 0; #10;

        // Novo par após reset
        IN1 = 16'd500; IN2 = 16'd600; TRIG = 1; #10;
        TRIG = 0; #10;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b EN=%b TRIG=%b IN1=%d IN2=%d | LARGEST=%d (0x%h) INDEX=%d", 
            $time, RST_COMP, EN_COMP, TRIG, IN1, IN2, LARGEST, LARGEST, INDEX);
    end

endmodule