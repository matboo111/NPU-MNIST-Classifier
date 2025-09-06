`timescale 1ns/1ps

// Testbench em Verilog-2001 para npu_top
// Fluxo: reset → config SSFR → enable FSM → aplicar vetores → ler saídas.

module tb_npu_top;

  // Clock/Reset
  reg        CLKEXT;
  reg        RST_GLO;

  // Controle alto nível
  reg        EN_FSM;
  reg        EN_CONFIG;
  reg        SEL_CON;

  // Dados de entrada
  reg  [7:0] DA, DB, DC, DD;

  // Controle debug (não usados normalmente)
  reg        RD_EN;
  reg        EN_PISO_DEB;
  reg        CLR_PISO_DEB;
  reg        SHIFT_DEB;

  // Saídas
  wire [7:0] D_OUT;
  wire       FULL;
  wire       EMPTY;

  // DUT
  npu_top dut (
    .CLKEXT(CLKEXT),
    .RST_GLO(RST_GLO),
    .EN_FSM(EN_FSM),
    .EN_CONFIG(EN_CONFIG),
    .DA(DA), .DB(DB), .DC(DC), .DD(DD),
    .RD_EN(RD_EN),
    .EN_PISO_DEB(EN_PISO_DEB),
    .CLR_PISO_DEB(CLR_PISO_DEB),
    .SHIFT_DEB(SHIFT_DEB),
    .SEL_CON(SEL_CON),
    .D_OUT(D_OUT),
    .FULL(FULL),
    .EMPTY(EMPTY)
  );

  // Clock 5 MHz
  initial CLKEXT = 1'b0;
  always #100 CLKEXT = ~CLKEXT;

  // -----------------------------
  // Tasks auxiliares
  // -----------------------------

  task apply_reset;
    integer cycles;
    begin
      cycles = 5;
      RST_GLO = 1'b1;
      repeat (cycles) @(posedge CLKEXT);
      RST_GLO = 1'b0;
      @(posedge CLKEXT);
    end
  endtask

  task cfg_ssfr;
    input [7:0] ssfr_hi;
    input [7:0] ssfr_lo;
    begin
      DA = ssfr_hi;
      DB = ssfr_lo;
      EN_CONFIG = 1'b1;
      @(posedge CLKEXT);
      EN_CONFIG = 1'b0;
      @(posedge CLKEXT);
    end
  endtask

  task push_quad;
    input [7:0] a, b, c, d;
    begin
      DA = a; DB = b; DC = c; DD = d;
      @(posedge CLKEXT);
      @(posedge CLKEXT);
    end
  endtask

  task pop_one;
    integer guard;
    begin
      guard = 0;
      if (!EMPTY) begin
        RD_EN = 1'b1;
        @(posedge CLKEXT);
        RD_EN = 1'b0;
      end else begin
        while (EMPTY && guard < 1000) begin
          @(posedge CLKEXT);
          guard = guard + 1;
        end
        RD_EN = 1'b1;
        @(posedge CLKEXT);
        RD_EN = 1'b0;
      end
    end
  endtask

  // Dump waves
  initial begin
    $dumpfile("tb_npu_top.vcd");
    $dumpvars(0, tb_npu_top);
  end

  // Sequência principal
  initial begin
    // Defaults
    EN_FSM       = 1'b0;
    EN_CONFIG    = 1'b0;
    SEL_CON      = 1'b1;
    RD_EN        = 1'b0;
    EN_PISO_DEB  = 1'b0;
    CLR_PISO_DEB = 1'b0;
    SHIFT_DEB    = 1'b0;
    DA = 0; DB = 0; DC = 0; DD = 0;

    // Reset
    apply_reset;

    // Liga FSM
    EN_FSM = 1'b1;
    @(posedge CLKEXT);

    // Configura SSFR = 16'h2280 (padrão)
    cfg_ssfr(8'h22, 8'h80);

    // Latência inicial
    repeat (4) @(posedge CLKEXT);

    // Vetores de entrada
    push_quad(8'd10, 8'd2, 8'd3, 8'd4);
    push_quad(8'd20, 8'd5, 8'd6, 8'd7);
    push_quad(8'd30, 8'd8, 8'd9, 8'd10);
    push_quad(8'd40, 8'd11, 8'd12, 8'd13);

    // Aguarda e faz leituras
    repeat (8) @(posedge CLKEXT);
    repeat (8) begin
      pop_one();
      @(posedge CLKEXT);
    end

    // Fim
    repeat (20) @(posedge CLKEXT);
    $display("[TB] Fim da simulação.");
    $finish;
  end

  // Monitor
  always @(posedge CLKEXT) begin
    if (RD_EN && !EMPTY) begin
      $display("%0t ns : RD -> D_OUT=0x%02x (FULL=%0b, EMPTY=%0b)",
               $time, D_OUT, FULL, EMPTY);
    end
  end

endmodule