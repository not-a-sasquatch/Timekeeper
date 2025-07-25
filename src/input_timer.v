//----------------------------------------------------------------------------
//                                                                          --
//                            input_timer.v                                 --
//                                                                          --
// Measures period of input logic signal.                                   --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
module input_timer  #(parameter DATA_WIDTH=20) 
    (
        // Inputs
        input wire clk,
        input wire rst,
        input wire signal,
        // Outputs
        output reg [DATA_WIDTH-1:0] period
    );

localparam [DATA_WIDTH-1:0] default_period = {1'b0, {(DATA_WIDTH-1){1'b0}}};

reg [DATA_WIDTH-1:0] counter;
reg polarity;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        period <= default_period;
        counter <= 0;
        polarity <= 1'b0;
    end else begin
        if(counter == {(DATA_WIDTH){1'b1}}) begin
            // Input signal timeout
            period <= default_period;
            counter <= 0;
            polarity <= 1'b0;
        end else if(signal && !polarity) begin
            period <= counter;
            counter <= 0;
            polarity <= 1'b1;
        end else if(!signal) begin
            counter <= counter + 1;
            polarity <= 1'b0;
        end else begin
            counter <= counter + 1;
        end
    end
end

endmodule
