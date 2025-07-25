//----------------------------------------------------------------------------
//                                                                          --
//                         muluint.v                                       --
//                                                                          --
// Unisgned integer multiplication circuitry                                --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------

module muluint #(parameter WIDTH=10) (               
    input wire rst,  
    input wire clk,            
    input wire enable,            
    output reg busy,             // calculation in progress
    output reg done,             // calculation is complete (high for one tick)
    output reg valid,            // result is valid
    input wire [WIDTH-1:0] a,    // operand A
    input wire [WIDTH-1:0] b,    // operand B
    output reg [2*WIDTH-1:0] result   // result = A + B
    );

reg [2*WIDTH-1:0] acopy, bcopy;    // accumulator 
reg [2*WIDTH-1:0] acc;    // accumulator 
reg [WIDTH-1:0] i;      // iteration counter


// Calculation control
/* verilator lint_off WIDTHTRUNC */
always @(posedge clk or posedge rst) begin
    done <= 0;
    if (rst) begin
        busy <= 0;
        done <= 0;
        valid <= 0;
        acc <= 0;
        acopy <= 0;
        bcopy <= 0;
    end else if (enable) begin
        valid <= 0;
        busy <= 1;
        acopy <= {{WIDTH{1'b0}}, a};
        bcopy <= {{WIDTH{1'b0}}, b};
        acc <= b[0] ? {{WIDTH{1'b0}}, a} : {(2*WIDTH){1'b0}};
        i <= 1;
    end else if (busy) begin
        if (i == 2*WIDTH-1) begin    
            busy <= 0;
            done <= 1;
            valid <= 1;
            result <= b[i] ? acc + {a, {WIDTH{1'b0}}} : acc;
        end else begin  // Next iteration
            i <= i + 1;
            acc <= b[i] ? acc + acopy << i : acc;;
        end
    end
end
/* verilator lint_off WIDTHTRUNC */
endmodule
