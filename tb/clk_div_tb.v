//----------------------------------------------------------------------------
//                                                                          --
//                         clk_div_tb.v                                     --
//                                                                          --
// Testbench for simulating clk_divider.v in verilator                      --
// Author: Connie S.                                                        --
//----------------------------------------------------------------------------
`include "src/clk_divider.v"

module clk_div_tb #(parameter DATA_WIDTH=20) (
    // inputs
    input wire rst,
    input wire clk,

    // outputs
    output reg mul_1, // x1
    output reg mul_2, // x2
    output reg mul_3, // x3
    output reg mul_4, // x4
    output reg mul_5, // x5
    output reg mul_8, // x8
    output reg mul_16, // x16
    output reg div_2, // /2
    output reg div_3, // /3
    output reg div_4, // /4
    output reg div_5, // /5
    output reg div_8, // /8
    output reg div_16 // /16
);

reg [DATA_WIDTH-1:0] period, duty, clk_counter;

initial begin
    clk_counter = {(DATA_WIDTH){1'b0}};
    period = (DATA_WIDTH)'('d500);
    duty = {{(DATA_WIDTH/2){1'b0}}, {(DATA_WIDTH/2){1'b1}}};
    duty = {{1'b1}, {(DATA_WIDTH-1){1'b0}}};
end

always @(posedge clk) begin
    clk_counter <= clk_counter + (DATA_WIDTH)'('b1);
    if(clk_counter > (DATA_WIDTH)'('d20000)) begin
        period <= (DATA_WIDTH)'('d2000);
    end /*else if(clk_counter > (DATA_WIDTH)'('d10000)) begin
        period <= (DATA_WIDTH)'('d1000);
    end*/
end

clk_divider #(.DATA_WIDTH(DATA_WIDTH)) clk_div(.rst(rst), .int_osc(clk), .master_period(period), .duty_cycle(duty), 
                    .mul_1(mul_1), .mul_2(mul_2), .mul_3(mul_3), .mul_4(mul_4), .mul_5(mul_5), .mul_8(mul_8), .mul_16(mul_16),
                    .div_2(div_2), .div_3(div_3), .div_4(div_4), .div_5(div_5), .div_8(div_8), .div_16(div_16));

endmodule
