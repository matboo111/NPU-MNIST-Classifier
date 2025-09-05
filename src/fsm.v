module downcounter (
    input  wire        CLKEXT,
    input  wire        RST_CTR,
    input  wire [7:0]  DB,
    input  wire [7:0]  DD,
    output reg         CTR_OUT
);
    reg [15:0] counter;
    assign counter = {DB, DD};
    
    always @(posedge CLKEXT or posedge RST_CTR) begin
        if (RST_CTR) begin
            Q  <= 4'b1111;
            TC <= 1'b0;
        end else if (EN) begin
            if (Q == 4'b0000) begin
                Q  <= 4'b1111;
                TC <= 1'b1;
            end else begin
                Q  <= Q - 1;
                TC <= 1'b0;
            end
        end
    end

endmodule