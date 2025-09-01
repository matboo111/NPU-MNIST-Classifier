module PISO #(
    parameter WIDTH = 8,
    parameter NUM_TAPS = 4
)(
    input                             CLR_PISO_OUT,
    input                             CLKEXT,
    input                             SHIFT_OUT,
    input                             EN_PISO_OUT,
    input  [WIDTH*NUM_TAPS-1:0] DATA_IN,
    output [WIDTH-1:0]                DATA_OUT
);

    reg [WIDTH-1:0] reg_data [0:NUM_TAPS-1];
    integer i;

    assign DATA_OUT = reg_data[NUM_TAPS-1];

    always @(posedge CLKEXT or posedge CLR_PISO_OUT)begin
        
        if(CLR_PISO_OUT) begin
            for(i=0; i<NUM_TAPS; i=i+1) begin
                reg_data[i] <= 0;
            end
        end else if (!SHIFT_OUT) begin
            for(i=0; i<NUM_TAPS; i=i+1) begin
                reg_data[i] <= DATA_IN[WIDTH*i +: WIDTH];
            end
        end else if (EN_PISO_OUT) begin
            //reg_data[NUM_TAPS-1] <= reg_data[NUM_TAPS-2];
            for(i=NUM_TAPS-1; i>0; i=i-1) begin
                reg_data[i] <= reg_data[i-1];
            end
        end
    end
endmodule