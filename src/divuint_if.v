//----------------------------------------------------------------------------
//                                                                          --
//                         divuint_if.v                                     --
//                                                                          --
// Interface to division circuity                                           --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
`include "src/divuint.v"

module divuint_if #(parameter DATA_WIDTH=10) (
    // inputs
    input wire rst,
    input wire clk,
    input wire [DATA_WIDTH-1:0] input0,
    input wire [DATA_WIDTH-1:0] input1,

    // outputs
    output reg [DATA_WIDTH-1:0] result,
    output reg valid_o
);

reg enable, busy, done, valid, dbz;
reg [DATA_WIDTH-1:0] quotient;
/* verilator lint_off UNUSEDSIGNAL */
reg [DATA_WIDTH-1:0] rem;
/* verilator lint_off UNUSEDSIGNAL */

divuint #(.WIDTH(DATA_WIDTH)) divider(.clk(clk), .rst(rst), .enable(enable), .busy(busy), .done(done), .valid(valid), .dbz(dbz), .a(input0), .b(input1), .quotient(quotient), .rem(rem));

// valid doesnt do anything - add check & latch when input changes

always @(posedge clk or posedge rst) begin
    if(rst) begin
        result <= 0;
        enable <= 0;
        valid_o <= 0;
    end else begin
        if(done && valid) begin
            result <= quotient;
            valid_o <= 1;
        end else if(dbz) begin
            result <= 0;
        end 
        if(enable) begin
            enable <= 0;
        end else if(~enable && ~busy) begin
            enable <= 1'b1;
        end
    end
end

endmodule
