`timescale 1ns/1ps

module tb_m16_bit;

    reg  [15:0] a, b;
    wire [15:0] ADD_OUT;

    m16_bit uut (
        .a(a),
        .b(b),
        .ADD_OUT(ADD_OUT)
    );

    initial begin
        $display("a                b                | ADD_OUT");
        $display("---------------------------------------------");

        // Soma normal (sem overflow)
        a = 16'd1000; b = 16'd2000; #10;
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        // Overflow positivo
        a = 16'h7FFF; b = 16'd1; #10;
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        // Overflow negativo
        a = 16'h8000; b = 16'hFFFF; #10; // -32768 + -1
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        // Soma negativa sem overflow
        a = 16'h8000; b = 16'd0; #10;
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        // Zero + Zero
        a = 16'd0; b = 16'd0; #10;
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        // Máximo negativo + máximo positivo
        a = 16'h8000; b = 16'h7FFF; #10;
        $display("%d (%h)   %d (%h)   | %d (%h)", a, a, b, b, ADD_OUT, ADD_OUT);

        $finish;
    end

endmodule