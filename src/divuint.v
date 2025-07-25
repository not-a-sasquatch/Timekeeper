//----------------------------------------------------------------------------
//                                                                          --
//                         divuint.v                                       --
//                                                                          --
// Unisgned integer division circuitry                                      --
// Modified from: https://projectf.io/posts/division-in-verilog/            --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
module divuint #(parameter WIDTH=10) (               
    input wire rst,  
    input wire clk,            
    input wire enable,            
    output reg busy,             // calculation in progress
    output reg done,             // calculation is complete (high for one tick)
    output reg valid,            // result is valid
    output reg dbz,              // divide by zero
    input wire [WIDTH-1:0] a,    // dividend
    input wire [WIDTH-1:0] b,    // divisor 
    output reg [WIDTH-1:0] quotient,  // result: quotient
    output reg [WIDTH-1:0] rem   // result: remainder
    );

    reg [WIDTH-1:0] b1;             // copy of divisor
    reg [WIDTH-1:0] quo, quo_next;  // intermediate quotient
    reg [WIDTH:0] acc, acc_next;    // accumulator (1 bit wider)
    //logic [$clog2(WIDTH)-1:0] i;      // iteration counter
    reg [WIDTH-1:0] i;      // iteration counter

    // Division algorithm iteration
    always @(*)begin
        if (acc >= {1'b0, b1}) begin
            acc_next = acc - b1;
            {acc_next, quo_next} = {acc_next[WIDTH-1:0], quo, 1'b1};
        end else begin
            {acc_next, quo_next} = {acc, quo} << 1;
        end
    end

    // Calculation control
    always @(posedge clk or posedge rst) begin
        done <= 0;
        if (rst) begin
            busy <= 0;
            done <= 0;
            valid <= 0;
            dbz <= 0;
            quotient <= 0;
            rem <= 0;
        end else if (enable) begin
            valid <= 0;
            i <= 0;
            if (b == 0) begin  // Catch divide by zero
                busy <= 0;
                done <= 1;
                dbz <= 1;
            end else begin
                busy <= 1;
                dbz <= 0;
                b1 <= b;
                {acc, quo} <= {{WIDTH{1'b0}}, a, 1'b0};  // Initialize calculation
            end
        end else if (busy) begin
            //if ({{(32-WIDTH){1'b0}}, i} == WIDTH-1) begin  // We're done (note - verilog assumes input parameters are width 32, so pad i with necessary 0's)
            /* verilator lint_off WIDTHEXPAND */
            if (i == WIDTH-1) begin    
                busy <= 0;
                done <= 1;
                valid <= 1;
                quotient <= quo_next;
                rem <= acc_next[WIDTH:1];  // Undo final shift
            end else begin  // Next iteration
                i <= i + 1;
                acc <= acc_next;
                quo <= quo_next;
            end
            /* verilator lint_off WIDTHEXPAND */
        end
        
    end
endmodule
