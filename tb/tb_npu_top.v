`timescale 1ns/1ps

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
      cycles = 1;
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
      EN_FSM = 1'b1;
      @(posedge CLKEXT);
      EN_CONFIG = 1'b0;
      EN_FSM = 1'b0;
      @(posedge CLKEXT);
    end
  endtask

  task push_quad;
    input [7:0] a, b, c, d;
    begin
      DA = a; DB = b; DC = c; DD = d;
      //@(posedge CLKEXT);
      //@(posedge CLKEXT);
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

//----------------------------- PISO_OUT(DEFAULT) -----------------------------
    // Reset
    apply_reset;
     // Liga FSM
    EN_FSM = 1'b1;
    @(posedge CLKEXT);
    EN_FSM = 1'b0;

    // Vetores de entrada
    @(negedge CLKEXT);
    push_quad(8'hD8, 8'h00, 8'hD8, 8'h08);
    @(negedge CLKEXT);
    push_quad(8'hD0, 8'hD0, 8'hD0, 8'hD0);
    @(negedge CLKEXT);
    push_quad(8'hD1, 8'hD1, 8'hD1, 8'hD1);
    @(negedge CLKEXT);
    push_quad(8'hD2, 8'hD2, 8'hD2, 8'hD2);
    @(negedge CLKEXT);
    push_quad(8'hD3, 8'hD3, 8'hD3, 8'hD3);
    @(negedge CLKEXT);
    push_quad(8'hD4, 8'hD4, 8'hD4, 8'hD4);
    @(negedge CLKEXT);
    push_quad(8'hD5, 8'hD5, 8'hD5, 8'hD5);
    @(negedge CLKEXT);
    push_quad(8'hD6, 8'hD6, 8'hD6, 8'hD6);
    @(negedge CLKEXT);
    push_quad(8'hD7, 8'hD7, 8'hD7, 8'hD7);
    //aguarda processaimento
    repeat (16) @(posedge CLKEXT);

//----------------------------- FIFO_OUT -----------------------------
    apply_reset;
    cfg_ssfr(8'b0000_0011, 8'b0000_0000); //SEL = 000(FIFO), FIFO = ENABLE, RESET_FIFO = DISABLE

    // Vetores de entrada
    @(negedge CLKEXT);
    push_quad(8'hD8, 8'h00, 8'hD8, 8'h08);
    @(negedge CLKEXT);
    push_quad(8'hD0, 8'hD0, 8'hD0, 8'hD0);
    @(negedge CLKEXT);
    push_quad(8'hD1, 8'hD1, 8'hD1, 8'hD1);
    RD_EN = 1'b1;
    @(negedge CLKEXT);
    push_quad(8'hD2, 8'hD2, 8'hD2, 8'hD2);
    @(negedge CLKEXT);
    push_quad(8'hD3, 8'hD3, 8'hD3, 8'hD3);
    @(negedge CLKEXT);
    push_quad(8'hD4, 8'hD4, 8'hD4, 8'hD4);
    @(negedge CLKEXT);
    push_quad(8'hD5, 8'hD5, 8'hD5, 8'hD5);
    RD_EN = 1'b0;
    @(negedge CLKEXT);
    push_quad(8'hD6, 8'hD6, 8'hD6, 8'hD6);
    @(negedge CLKEXT);
    push_quad(8'hD7, 8'hD7, 8'hD7, 8'hD7);
    //aguarda processamento
    repeat (16) @(posedge CLKEXT);

    //----------------------------- AUTO_COMP -----------------------------
    apply_reset;
    cfg_ssfr(8'b0100_0100, 8'b1000_0000); //SEL = 010(AUTO_COMP), EN_COMP = ENABLE, RESET_COMP = DISABLE

    // Vetores de entrada
    @(negedge CLKEXT);
    push_quad(8'hD8, 8'h00, 8'hD8, 8'h08);
    @(negedge CLKEXT);
    push_quad(8'hD0, 8'hD0, 8'hD0, 8'hD0);
    @(negedge CLKEXT);
    push_quad(8'hD1, 8'hD1, 8'hD1, 8'hD1);
    @(negedge CLKEXT);
    push_quad(8'hD2, 8'hD2, 8'hD2, 8'hD2);
    @(negedge CLKEXT);
    push_quad(8'hD3, 8'hD3, 8'hD3, 8'hD3);
    @(negedge CLKEXT);
    push_quad(8'hD4, 8'hD4, 8'hD4, 8'hD4);
    @(negedge CLKEXT);
    push_quad(8'hD5, 8'hD5, 8'hD5, 8'hD5);
    @(negedge CLKEXT);
    push_quad(8'hD6, 8'hD6, 8'hD6, 8'hD6);
    @(negedge CLKEXT);
    push_quad(8'hD7, 8'hD7, 8'hD7, 8'hD7);
    //aguarda processamento
    repeat (16) @(posedge CLKEXT);

    $display("[TB] Fim da simulação.");
    $finish;
  end

  /* Monitor
  always @(posedge CLKEXT) begin
    if (RD_EN && !EMPTY) begin
      $display("%0t ns : RD -> D_OUT=0x%02x (FULL=%0b, EMPTY=%0b)",
               $time, D_OUT, FULL, EMPTY);
    end
  end
*/

endmodule