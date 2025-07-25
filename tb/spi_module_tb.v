//----------------------------------------------------------------------------
//                                                                          --
//                            spi_module_tb.v                               --
//                                                                          --
// Testbench for simulating spi_module.v in verilator                       --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------

module spi_module_tb
    #(
        parameter spi_word_send_len = 8,
        parameter spi_word_rcv_len = 8
    )
    (
        input wire clk,
        input wire rst,
        output wire sclk_o, // SPI clk out
        output wire cs_o,   // chip select out
        output wire data_o,   // controller out peripheral in
        output wire processing_word,
        output wire processing_transaction,
        output reg [spi_word_rcv_len - 1:0] data_word_rcv,
        output reg ready,
        output reg word_done,
        output reg transaction_done
    );


wire spi_clk;
reg [3:0] divcounter;
reg data_i;
// Clock divider
always @(posedge clk or posedge rst) begin
	if(rst) begin
		divcounter <= 4'b0;
    end else  begin 
        divcounter <= divcounter + 1;
    end
end
assign spi_clk = divcounter[3];

reg [11:0] counter2;
reg process_next_word;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		counter2 <= 12'b0;
        process_next_word <= 1'b0;
        data_i <= 1'b1;
    end else  begin 
        if(counter2 >= 12'd3200) begin
            counter2 <= 12'd0;
        end else if(counter2 == 12'd2400) begin
            counter2 <= counter2 + 1;
            process_next_word <= 1'b1;
            data_i <= 1'b1;
        end else if(counter2 ==12'd1600) begin
            counter2 <= counter2 + 1;
            process_next_word <= 1'b1;
            data_i <= 1'b0;
        end else if(counter2 == 12'd800) begin
            counter2 <= counter2 + 1;
            process_next_word <= 1'b1;
        end else begin
            counter2 <= counter2 + 1;
            process_next_word <= 1'b0;
        end
        
    end
end

reg [7:0] spi_data_send = 8'b00001111;

spi_module #(.cpol(1'b0), .cpha(1'b0), .invert_data_order(1'b0), .spi_controller(1'b1), .spi_word_send_len(spi_word_send_len), .spi_word_rcv_len(spi_word_rcv_len)) spi_test
                    (
                        .clk(clk), .rst(rst), .sclk_o(sclk_o), .sclk_i(spi_clk), .cs_o(cs_o), .cs_i(1'b0), .data_o(data_o),
                        .data_i(data_i), .processing_word(processing_word), .process_next_word(process_next_word), .processing_transaction(processing_transaction),
                        .data_word_send(spi_data_send), .data_word_rcv(data_word_rcv), .num_word_send(5'd1), .num_word_rcv(5'd2),
                        .ready(ready), .word_done(word_done), .transaction_done(transaction_done)
                    );

endmodule

