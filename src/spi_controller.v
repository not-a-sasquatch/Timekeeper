//----------------------------------------------------------------------------
//                                                                          --
//                            spi_controller.v                              --
//                                                                          --
// Interface to SPI module. Handles custom commands for MP3008 ADC.         --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
`include "src/spi_module.v"

module spi_controller
    (
        input wire clk,                                      // system clk
        input wire rst,                                      // reset
        output wire sclk_o,                                  // SPI clk out
        output wire cs_o,                                    // chip select out
        output wire data_o,                                  // SPI data ouput line
        input wire data_i,                                   // SPI data input line
        output reg [9:0] ch0_word,  // data word to send
        output reg [9:0] ch1_word,   // data word received 
        output reg valid                                    // data valid signal
    );

localparam cpol = 1'b0;                          // SPI clock polarity
localparam cpha = 1'b0;                          // SPI clock phase
localparam spi_word_send_len = 4;                // number of bits in send word
localparam spi_word_rcv_len = 20;                 // number of bits in receive word
localparam num_word_send = 5'd1;
localparam num_word_rcv = 5'd1;



// SPI clock divider circuitry
reg spi_clk;
reg [15:0] spi_clk_cnt;
localparam spi_period = 16'd100;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        spi_clk <= 0;
        spi_clk_cnt <= 0;
    end else begin
        if(spi_clk_cnt < spi_period) begin
            spi_clk_cnt <= spi_clk_cnt + 16'd1;
        end else begin
            spi_clk <= ~spi_clk;
            spi_clk_cnt <= 0;
        end
    end
end

// Spi sequence controller
reg process_next_word;
/* verilator lint_off UNUSEDSIGNAL */
reg processing_word;
reg processing_transaction;
reg word_done;
/* verilator lint_off UNUSEDSIGNAL */
reg transaction_done;
reg ready;

reg [2:0] spi_status;
localparam delay = 3'd0;
localparam send = 3'd1;
localparam pause = 3'd2;
localparam rcv = 3'd3;
localparam finish = 3'd4;

reg [15:0] delay_clk_cnt;
localparam delay_period = 16'd5000;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        spi_status <= delay;
        delay_clk_cnt <= 0;
        valid <= 1'b0;
        ch0_word <= 10'd0;
        ch1_word <= 10'd0;
        process_next_word <= 1'b0;
    end else begin
        case(spi_status)
            delay: begin
                valid <= 1'b0;
                if(delay_clk_cnt < delay_period) begin
                    delay_clk_cnt <= delay_clk_cnt + 16'd1;
                end else begin
                    if(ready) begin
                        delay_clk_cnt <= 0;
                        spi_status <= send;
                    end
                end
            end
            send: begin
                process_next_word <= 1'b1;
                spi_status <= pause;
            end
            pause: begin
                process_next_word <= 1'b0;
                if(processing_transaction && ready) begin
                    spi_status <= rcv;
                end
            end
            rcv: begin
                process_next_word <= 1'b1;
                spi_status <= finish;
            end
            finish: begin
                process_next_word <= 1'b0;
                if(transaction_done) begin
                    spi_status <= delay;
                    ch0_word <= data_word_rcv[9:0];
                    ch1_word <= data_word_rcv[19:10];
                    valid <= 1'b1;
                end
            end
            default: begin
                spi_status <= delay;
            end
        endcase
    end
end

// 
reg [19:0] data_word_rcv;
reg [3:0] data_word_send = 4'b1110;


spi_module #(.cpol(cpol), .cpha(cpha), .invert_data_order(1'b0), .spi_controller(1'b1), .spi_word_send_len(spi_word_send_len), .spi_word_rcv_len(spi_word_rcv_len)) spi_ADC
            (
                .clk(clk), .rst(rst), .sclk_o(sclk_o), .sclk_i(spi_clk), .cs_o(cs_o), .cs_i(1'b0), .data_o(data_o),
                .data_i(data_i), .processing_word(processing_word), .process_next_word(process_next_word), .processing_transaction(processing_transaction),
                .data_word_send(data_word_send), .data_word_rcv(data_word_rcv), .num_word_send(num_word_send), .num_word_rcv(num_word_rcv),
                .ready(ready), .word_done(word_done), .transaction_done(transaction_done)
            );

endmodule
