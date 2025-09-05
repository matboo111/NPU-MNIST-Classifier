module ssfr (
    input  wire        CLKEXT,
    input  wire        RST,
    input  wire [7:0]  DA,
    input  wire [7:0]  DB,
    input  wire        EN_CONFIG,
    output wire [15:0] SSFR
)

    reg [15:0] ssfr_reg;
    assign SSFR = ssfr_reg; 
    always @(posedge CLKEXT or posedge RST) begin
        if (RST) begin
            ssfr_reg <= 16'b0010_0010_1000_0000;
        end else if (EN_CONFIG) begin
            ssfr_reg <= {DB, DA};
        end
    end

endmodule