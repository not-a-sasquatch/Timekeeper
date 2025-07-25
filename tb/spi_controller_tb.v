//----------------------------------------------------------------------------
//                                                                          --
//                            spi_controller_tb.v                           --
//                                                                          --
// Testbench for simulating spi_controller.v in verilator                   --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
`include "src/spi_controller.v"

module spi_controller_tb
    (
        input wire clk,
        input wire rst,
        output wire sclk_o, // SPI clk out
        output wire cs_o,   // chip select out
        output wire data_o,   // controller out peripheral in
        output reg [9:0] ch0_word,
        output reg [9:0] ch1_word,
        output reg valid
    );

reg [15:0] counter;
reg data_i;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		counter <= 16'b0;
        data_i <= 1'b0;
    end else  begin 
        if(counter >= 16'd16000) begin
            counter <= 16'd0;
            data_i <= 1'b0;
        end else if(counter == 16'd8000) begin
            counter <= counter + 1;
            data_i <= 1'b1;
        end else begin
            counter <= counter + 1;
        end        
    end
end

spi_controller spi_cntr (.clk(clk), .rst(rst), .sclk_o(sclk_o), .cs_o(cs_o), .data_o(data_o), .data_i(data_i), .ch0_word(ch0_word), .ch1_word(ch1_word), .valid(valid));

endmodule
