module auto_comparator (
    input  wire        CLKEXT,
    input  wire        RST_COMP,
    input  wire        EN_COMP,
    input  wire        TRIG,
    input  wire [15:0] IN1,
    input  wire [15:0] IN2,
    output reg  [15:0] LARGEST,
    output reg  [7:0]  INDEX
);
    reg [7:0] next_idx;

    always @(posedge CLKEXT or posedge RST_COMP) begin
        if (RST_COMP) begin
            LARGEST <= 16'h8000;
            INDEX   <= 0;
            next_idx<= 1;
        end else if (EN_COMP && TRIG) begin
            if ($signed(IN1) > $signed(LARGEST)) begin
                LARGEST <= IN1;
                INDEX   <= next_idx;
            end
            if ($signed(IN2) > $signed(LARGEST)) begin
                LARGEST <= IN2;
                INDEX   <= next_idx + 1;
            end
            next_idx <= next_idx + 2;
        end
    end
endmodule