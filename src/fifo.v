module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 128
)(
    input  wire                  CLKEXT,
    input  wire                  RST,
    input  wire                  WR_EN,
    input  wire                  RD_EN,
    input  wire [DATA_WIDTH-1:0] DATA_IN,
    output reg  [DATA_WIDTH-1:0] DATA_OUT,
    output wire                  FULL,
    output wire                  EMPTY
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    reg [$clog2(DEPTH):0] fifo_count;

    assign FULL  = (fifo_count == DEPTH);
    assign EMPTY = (fifo_count == 0);
    assign count = fifo_count;

    always @(posedge CLKEXT or posedge RST) begin
        if (RST) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            fifo_count <= 0;
            DATA_OUT <= 0;
        end else begin
            // Write operation
            if (WR_EN && !FULL) begin
                mem[wr_ptr] <= DATA_IN;
                wr_ptr <= wr_ptr + 1;
            end
            // Read operation
            if (RD_EN && !EMPTY) begin
                DATA_OUT <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end
            // Update count
            case ({WR_EN && !FULL, RD_EN && !EMPTY})
                2'b10: fifo_count <= fifo_count + 1;
                2'b01: fifo_count <= fifo_count - 1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

endmodule