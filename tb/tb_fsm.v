`timescale 1ns/1ps

module tb_fsm;

    reg        CLKEXT;
    reg        RST;
    reg        EN_FSM;
    reg [7:0]  DB, DD;
    wire [15:0] CON_SIG;

    fsm uut (
        .CLKEXT(CLKEXT),
        .RST(RST),
        .EN_FSM(EN_FSM),
        .DB(DB),
        .DD(DD),
        .CON_SIG(CON_SIG)
    );

    // Clock generation
    initial CLKEXT = 0;
    always #5 CLKEXT = ~CLKEXT;

    initial begin
        // Inicialização
        RST = 1;
        EN_FSM = 0;
        DB = 8'h00;
        DD = 8'h05;
        #12;
        RST = 0;

        // Testa FSM desabilitada
        EN_FSM = 0;
        #20;

        // Habilita FSM e observa transições
        EN_FSM = 1;
        #100;

        // Desabilita FSM durante operação
        EN_FSM = 0;
        #20;

        // Testa novo valor de contador
        RST = 1;
        DB = 8'h01;
        DD = 8'h00;
        #10;
        RST = 0;
        EN_FSM = 1;
        #100;

        $finish;
    end

    initial begin
        $monitor("T=%0t | RST=%b EN_FSM=%b DB=%h DD=%h | CON_SIG=%h", 
            $time, RST, EN_FSM, DB, DD, CON_SIG);
    end

endmodule