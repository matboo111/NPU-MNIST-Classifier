module ffd #(
    parameter WIDTH = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);

always @(posedge clk or posedge rst) begin
    if (rst)
        q <= {WIDTH{1'b0}};
    else
        q <= d;
end

endmodule