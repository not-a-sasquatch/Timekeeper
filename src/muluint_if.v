//----------------------------------------------------------------------------
//                                                                          --
//                         muluint_if.v                                     --
//                                                                          --
// Interface to multiplication circuity                                     --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
`include "src/muluint.v"

module muluint_if #(parameter DATA_WIDTH=10) (
    // inputs
    input wire rst,
    input wire clk,
    input wire [DATA_WIDTH-1:0] input0,
    input wire [DATA_WIDTH-1:0] input1,

    // outputs
    output reg [2*DATA_WIDTH-1:0] result,
    output reg valid_o
);

reg enable, busy, done, valid;
reg [2*DATA_WIDTH-1:0] sum;

muluint #(.WIDTH(DATA_WIDTH)) multiplier(.clk(clk), .rst(rst), .enable(enable), .busy(busy), .done(done), .valid(valid), .a(input0), .b(input1), .result(sum));
// valid doesnt do anything  - add check & latch when input changes
always @(posedge clk or posedge rst) begin
    if(rst) begin
        result <= 0;
        enable <= 0;
        valid_o <= 0;
    end else begin
        if(done && valid) begin
            result <= sum;
            valid_o <= 1;
        end
        if(enable) begin
            enable <= 0;
        end else if(~enable && ~busy) begin
            enable <= 1'b1;
        end
    end
end

endmodule
