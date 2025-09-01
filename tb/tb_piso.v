`timescale 1ns/1ps

module tb_PISO_OUT;

    parameter WIDTH = 8;
    parameter NUM_TAPS = 4;

    reg CLKEXT, CLR_PISO_OUT, SHIFT_OUT, EN_PISO_OUT;
    reg [WIDTH*NUM_TAPS-1:0] DATA_IN;
    wire [WIDTH-1:0] DATA_OUT;

    PISO #(
        .WIDTH(WIDTH),
        .NUM_TAPS(NUM_TAPS)
    ) uut (
        .CLR_PISO_OUT(CLR_PISO_OUT),
        .CLKEXT(CLKEXT),
        .SHIFT_OUT(SHIFT_OUT),
        .EN_PISO_OUT(EN_PISO_OUT),
        .DATA_IN(DATA_IN),
        .DATA_OUT(DATA_OUT)
    );

    // Clock generation
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    initial begin
        CLR_PISO_OUT = 1;
        SHIFT_OUT = 0;
        EN_PISO_OUT = 0;
        DATA_IN = 0;
        #12;
        CLR_PISO_OUT = 0;

        // Carrega dados paralelos
        DATA_IN = {8'hAA, 8'hBB, 8'hCC, 8'hDD}; // reg_data[3]=AA, [2]=BB, [1]=CC, [0]=DD
        SHIFT_OUT = 0;
        EN_PISO_OUT = 0;
        #10;

        // Ativa shift
        SHIFT_OUT = 1;
        EN_PISO_OUT = 1;
        #10;
        #10;
        #10;
        #10;

        // Reset durante operação
        CLR_PISO_OUT = 1;
        #10;
        CLR_PISO_OUT = 0;
        #10;

        $finish;
    end

    initial begin
        $monitor("T=%0t | CLR=%b SHIFT=%b EN=%b DATA_IN=%h | DATA_OUT=%h", 
            $time, CLR_PISO_OUT, SHIFT_OUT, EN_PISO_OUT, DATA_IN, DATA_OUT);
    end

endmodule