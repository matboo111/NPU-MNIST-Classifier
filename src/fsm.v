module fsm (
    input  wire        CLKEXT,
    input  wire        RST,
    input  wire        EN_FSM,
    input  wire [7:0]  DB,
    input  wire [7:0]  DD,
    output wire [15:0] CON_SIG
);
//---------------- FSM_ACC STATES ----------------
    localparam IDLE       = 3'b000;
    localparam BIAS       = 3'b001;
    localparam ACC        = 3'b010;
    localparam LAST       = 3'b011;
    localparam WAIT       = 3'b100;

//---------------- FSM_OUT STATES ----------------
    localparam OUT_IDLE   = 3'b000;
    localparam OUT_S1     = 3'b001;
    localparam OUT_S2     = 3'b010;
    localparam OUT_S3     = 3'b011;
    localparam OUT_S4     = 3'b100;
    localparam OUT_S5     = 3'b101;


    reg OUT_DONE;
    reg ACC_FLAG;

    reg CTR_OUT;
    reg EN_BUF_IN;
    reg CLR_BUF_IN;
    reg EN_MAC;
    reg RST_MAC;
    reg EN_reLU;
    reg SHIFT_OUT;
    reg EN_PISO_OUT;
    reg CLR_PISO_OUT;
    reg WR_EN;

    reg [2:0] state_acc,state_out;
    reg [15:0] counter;

    assign CON_SIG[15]  = EN_BUF_IN;
    assign CON_SIG[14]  = CLR_BUF_IN;
    assign CON_SIG[13]  = EN_MAC;
    assign CON_SIG[12]  = RST_MAC;
    assign CON_SIG[11]  = EN_reLU;
    assign CON_SIG[10]  = SHIFT_OUT;
    assign CON_SIG[9]   = EN_PISO_OUT;
    assign CON_SIG[8]   = CLR_PISO_OUT;
    assign CON_SIG[7]   = WR_EN;
    assign CON_SIG[6:0] = 7'b0000000; // Sinais não utilizados

    always @(posedge CLKEXT or posedge RST) begin : DOWNCOUNTER
        if (RST) begin
            counter <= {DB, DD};
            CTR_OUT <= 1'b0;
        end else begin
            counter <= counter - 1;
            if (counter == 16'b1) begin
                CTR_OUT <= 1'b1;
            end else if (counter == 16'b0) begin
                counter <= {DB, DD};
                CTR_OUT <= 1'b0;
            end else begin
                CTR_OUT <= 1'b0;
            end
        end
    end

    always @(posedge CLKEXT or posedge RST) begin : FSM_OUT
        if (RST) begin
            SHIFT_OUT   <= 1'b0;
            EN_PISO_OUT <= 1'b0;
            WR_EN       <= 1'b0;
            OUT_DONE    <= 1'b0;
            state_out   <= OUT_IDLE;
        end
        else begin
            case (state_out)
                OUT_IDLE: begin
                    SHIFT_OUT   <= 1'b1;
                    EN_PISO_OUT <= 1'b0;
                    WR_EN       <= 1'b0;
                    OUT_DONE    <= 1'b0;
                    if (EN_reLU) begin
                        state_out <= OUT_S1;
                    end
                    else begin
                        state_out <= OUT_IDLE;
                    end
                end

                OUT_S1: begin
                    SHIFT_OUT   <= 1'b0;
                    EN_PISO_OUT <= 1'b1;
                    WR_EN       <= 1'b0;
                    OUT_DONE    <= 1'b0;
                    state_out   <= OUT_S2;
                end

                OUT_S2: begin
                    SHIFT_OUT   <= 1'b1;
                    EN_PISO_OUT <= 1'b1;
                    WR_EN       <= 1'b1;
                    OUT_DONE    <= 1'b0;
                    state_out   <= OUT_S3;
                end

                OUT_S3: begin
                    SHIFT_OUT   <= 1'b1;
                    EN_PISO_OUT <= 1'b1;
                    WR_EN       <= 1'b1;
                    OUT_DONE    <= 1'b0;
                    state_out   <= OUT_S4;
                end

                OUT_S4: begin
                    SHIFT_OUT   <= 1'b1;
                    EN_PISO_OUT <= 1'b1;
                    WR_EN       <= 1'b1;
                    OUT_DONE    <= 1'b0;
                    state_out   <= OUT_S5;
                end

                OUT_S5: begin
                    SHIFT_OUT   <= 1'b1;
                    EN_PISO_OUT <= 1'b0;
                    WR_EN       <= 1'b1;
                    OUT_DONE    <= 1'b1;
                    state_out   <= OUT_IDLE;
                end

                default: begin
                    SHIFT_OUT   <= 1'b0;
                    EN_PISO_OUT <= 1'b0;
                    WR_EN       <= 1'b0;
                    OUT_DONE    <= 1'b0;
                    state_out   <= OUT_IDLE;
                end
            endcase
        end
    end

    always @(posedge CLKEXT or posedge RST) begin : FSM_ACC
        if (RST) begin
            EN_BUF_IN    <= 1'b0;
            CLR_BUF_IN   <= 1'b1;
            EN_MAC       <= 1'b0;
            RST_MAC      <= 1'b1;
            CLR_PISO_OUT <= 1'b1;
            EN_reLU      <= 1'b0;
            ACC_FLAG     <= 1'b0;
            state_acc    <= IDLE;
        end
        else begin
            case(state_acc)
                IDLE: begin
                    EN_BUF_IN    <= 1'b0;
                    CLR_BUF_IN   <= 1'b1;
                    EN_MAC       <= 1'b0;
                    RST_MAC      <= 1'b0;
                    CLR_PISO_OUT <= 1'b1;
                    EN_reLU      <= 1'b0;
                    ACC_FLAG     <= 1'b0;
                    if (EN_FSM) begin
                        state_acc <= BIAS;
                    end
                    else begin
                        state_acc <= IDLE;
                    end
                end

                BIAS: begin
                    EN_BUF_IN    <= 1'b0;
                    CLR_BUF_IN   <= 1'b1;
                    EN_MAC       <= 1'b1;
                    RST_MAC      <= 1'b1;
                    CLR_PISO_OUT <= 1'b0;
                    state_acc    <= ACC;
                    if (ACC_FLAG) begin
                        EN_reLU  <= 1'b1;
                    end
                    else begin
                        EN_reLU  <= 1'b0;
                    end
                end

                ACC: begin
                    EN_BUF_IN    <= 1'b1;
                    CLR_BUF_IN   <= 1'b0;
                    EN_MAC       <= 1'b1;
                    RST_MAC      <= 1'b0;
                    CLR_PISO_OUT <= 1'b0;
                    EN_reLU      <= 1'b0;
                    ACC_FLAG     <= 1'b1;
                    if      (!EN_FSM & CTR_OUT) begin
                        state_acc <= LAST;
                    end
                    else if (EN_FSM & CTR_OUT)begin
                        state_acc <= BIAS;
                    end
                    else begin
                        state_acc <= ACC;
                    end
                end

                LAST: begin
                    EN_BUF_IN    <= 1'b0;
                    CLR_BUF_IN   <= 1'b0;
                    EN_MAC       <= 1'b1;
                    RST_MAC      <= 1'b0;
                    CLR_PISO_OUT <= 1'b0;
                    EN_reLU      <= 1'b1;
                    state_acc    <= WAIT;
                end

                WAIT: begin
                    EN_BUF_IN    <= 1'b0;
                    CLR_BUF_IN   <= 1'b0;
                    EN_MAC       <= 1'b0;
                    RST_MAC      <= 1'b0;
                    CLR_PISO_OUT <= 1'b0;
                    EN_reLU      <= 1'b0;
                    if (OUT_DONE) begin
                        state_acc <= IDLE;
                    end
                    else begin
                        state_acc <= WAIT;
                    end
                end

                default: begin
                    EN_BUF_IN    <= 1'b0;
                    CLR_BUF_IN   <= 1'b1;
                    EN_MAC       <= 1'b0;
                    RST_MAC      <= 1'b1;
                    CLR_PISO_OUT <= 1'b1;
                    EN_reLU      <= 1'b0;
                    ACC_FLAG     <= 1'b0;
                    state_acc    <= IDLE;
                end

            endcase
        end
    end

endmodule