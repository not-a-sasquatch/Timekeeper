//----------------------------------------------------------------------------
//                                                                          --
//                            spi_module.v                                  --
//                                                                          --
// Arbitrary SPI module. Can act as a SPI controller or peripheral.         --
// Modified from: https://github.com/janschiefer/verilog_spi/tree/master    --
// Author Connie S.                                                         --
//----------------------------------------------------------------------------
module spi_module
    #(
        parameter cpol = 1'b0,                          // SPI clock polarity
        parameter cpha = 1'b0,                          // SPI clock phase
        parameter invert_data_order = 1'b0,             // 1'b1 - word starts at bit last bit, 1'b0 - word starts at bt 0
        parameter spi_controller = 1'b1,                // 1'b1 - controller, 1'b0 - peripheral
        parameter spi_word_send_len = 8,                // number of bits in send word
        parameter spi_word_rcv_len = 8                  // number of bits in receive word
    )

    (
        input wire clk,                                      // system clk
        input wire rst,                                      // reset
        output wire sclk_o,                                  // SPI clk out
        input wire sclk_i,                                   // SPI clk in
        output wire cs_o,                                    // chip select out
        input wire cs_i,                                     // chip select in
        output wire data_o,                                  // SPI data ouput line
        input wire data_i,                                   // SPI data input line
        input wire process_next_word,                        // trigger to process next word 
        output reg processing_word,                          // processing word flag          
        output wire processing_transaction,                  // processing transaction flag
        input wire [spi_word_send_len - 1:0] data_word_send,  // data word to send
        output reg [spi_word_rcv_len - 1:0] data_word_rcv,   // data word received 
        input wire [4:0] num_word_send,                       // number of data words to send
        input wire [4:0] num_word_rcv,                        // number of data words to read
        output reg ready,                                    // ready to be triggered
        output reg word_done,                                // word finished processing
        output reg transaction_done                          // finished with entire transaction
    );

// Internal signal to activate chip select signal circuitry (and enable data_out signal).
reg activate_cs;
// Internal signal to activate SPI clk signal circuitry 
reg activate_sclk;

assign cs_o = activate_cs ? 1'b0 : 1'b1;
assign sclk_o = activate_sclk ? sclk_i : cpol;

// Internal signal to ignore first edge of SPI clk
reg ignore_first_edge;

// Internal signals tracking rising/falling edge for SPI clk
wire rising_sclk_edge;
wire falling_sclk_edge;

// Process next word latch: necessary to synchronize with delay polarity signal
reg process_next_word_latch;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        process_next_word_latch <= 1'b0;
    end else begin
        if(process_next_word) begin
            process_next_word_latch <= 1'b1;
        end else if(spi_status != idle) begin
            process_next_word_latch <= 1'b0;
        end
    end
    
end

// SPI clk edge detection 
reg sclk_delay;
always @(posedge clk) begin
    sclk_delay <= sclk_i;
end
assign rising_sclk_edge = sclk_i & ~sclk_delay;
assign falling_sclk_edge = ~sclk_i & sclk_delay;

// SPI FSM
reg [2:0] spi_status;
localparam idle = 3'd0;
localparam cycle_send = 3'd1;
localparam cycle_rcv = 3'd2;
localparam cycle_wait = 3'd3;
localparam finish = 3'd4;
reg [4:0] counter_word_send;
reg [4:0] counter_word_rcv;

// Processing transaction signal
assign processing_transaction = (spi_status == idle) ? 1'b0:1'b1;

// cpol = 0, cpha = 0: data sampled on rising edge and shifted out on the falling edge
// cpol = 0, cpha = 1: data sampled on the falling edge and shifted out on the rising edge
// cpol = 1, cpha = 0: data sampled on the falling edge and shifted out on the rising edge
// cpol = 1, cpha = 1: data sampled on the rising edge and shifted out on the falling edge

// Internal signal to delay start of read/write cycle
wire delay_pol = cpha ? (cpol ? rising_sclk_edge : falling_sclk_edge) : (cpol ? sclk_i : !sclk_i);	
// Internal signal to trigger data read
wire get_number_edge = cpha ? (cpol ? rising_sclk_edge : falling_sclk_edge):(cpol ? falling_sclk_edge : rising_sclk_edge);	
// Internal signal to trigger data write and bit counter increment
wire put_number_edge = cpha ? (cpol ? falling_sclk_edge : rising_sclk_edge):(cpol ? rising_sclk_edge : falling_sclk_edge);
	
// Internal chip select signal
wire cs = activate_cs ? (spi_controller ? cs_o : cs_i) : 1'b1;

// Bit counter for current word being processed
reg [31:0] bit_counter;

// SPI data out signal
assign data_o = (processing_word && activate_cs && (spi_status == cycle_send)) ? data_word_send[bit_counter] : 1'b0;

always @(posedge clk or posedge rst) begin
    /* verilator lint_off CASEINCOMPLETE */
    if(rst) begin
        activate_cs <= 1'b0;
        activate_sclk <= 1'b0;      
        word_done <= 1'b0;
        counter_word_send <= 5'd0;
        counter_word_rcv <= 5'd0;
        bit_counter <= invert_data_order ? ((spi_controller ? spi_word_send_len : spi_word_rcv_len) - 1) : ('sd0);
        spi_status <= idle;
        ready <= 1'b0;
        transaction_done <= 1'b0;
        processing_word <= 1'b0;
        data_word_rcv <= 'sd0;
    end else begin
        case(spi_status)
            idle: begin
                if(process_next_word_latch && delay_pol) begin
                    ignore_first_edge <= 1'b0;
                    activate_cs <= 1'b1;
                    activate_sclk <= 1'b1;      
                    word_done <= 1'b0;
                    counter_word_send <= 5'd0;
                    counter_word_rcv <= 5'd0;
                    ready <= 1'b0;
                    processing_word <= 1'b1;
                    data_word_rcv <= 'sd0;
                    if(spi_controller) begin
                        spi_status <= cycle_send;
                        bit_counter <= invert_data_order ? (spi_word_send_len - 1) : ('sd0);
                    end else begin
                        spi_status <= cycle_rcv;
                        bit_counter <= invert_data_order ? (spi_word_rcv_len - 1) : ('sd0);
                    end
                end else begin
                    ready <= 1'b1;
                    activate_cs <= 1'b0;
                    activate_sclk <= 1'b0;
                    transaction_done <= 1'b0;
                end
            end
            cycle_send: begin
                    if(!cs && !word_done) begin
                        if(put_number_edge) begin
                            if(cpha && !ignore_first_edge) begin
                                ignore_first_edge <= 1'b1;
                            end else begin
                                if(bit_counter == (invert_data_order ? ('sd0) : (spi_word_send_len - 1))) begin
                                    activate_cs <= 1'b1;//1'b0;
                                    activate_sclk <= 1'b0;
                                    bit_counter <= invert_data_order ? (spi_word_send_len-1) : 0;
                                    counter_word_send <= counter_word_send + 1;
                                    word_done <= 1'b1;
                                    processing_word <= 1'b0;
                                end else begin
                                    bit_counter <= invert_data_order ? (bit_counter - 1) : (bit_counter + 1);
                                    word_done <= 1'b0;
                                    processing_word <= 1'b1;
                                end
                            end
                        end
                    end else begin
                        word_done <= 1'b0;
                        spi_status <= cycle_wait;
                    end
            end
            cycle_wait: begin
                if((spi_controller && (counter_word_rcv >= num_word_rcv)) || (!spi_controller && (counter_word_send >= num_word_send)))begin
                    spi_status <= finish;
                end else if(process_next_word_latch && delay_pol) begin
                    ignore_first_edge <= 1'b0;
                    activate_cs <= 1'b1;
                    activate_sclk <= 1'b1;      
                    word_done <= 1'b0;
                    processing_word <= 1'b1;
                    ready <= 1'b0;
                    if(spi_controller) begin
                        if(counter_word_send < num_word_send) begin
                            spi_status <= cycle_send;
                        end else begin
                            spi_status <= cycle_rcv;
                        end
                    end else begin
                        if(counter_word_rcv < num_word_rcv) begin
                            spi_status <= cycle_rcv;
                        end else begin
                            spi_status <= cycle_send;
                        end
                    end
                end else begin
                    ready <= 1'b1;
                    activate_sclk <= 1'b0;
                end
            end
            cycle_rcv: begin
                    if(!cs && !word_done) begin
                        if(get_number_edge) begin
                            data_word_rcv[bit_counter] <= data_i;
                        end
                        if(put_number_edge) begin
                            if(cpha && !ignore_first_edge) begin
                                ignore_first_edge <= 1'b1;
                            end else begin
                                if(bit_counter == (invert_data_order ? ('sd0) : (spi_word_rcv_len - 1))) begin
                                    activate_cs <= 1'b1;//1'b0;
                                    activate_sclk <= 1'b1;
                                    bit_counter <= invert_data_order ? (spi_word_rcv_len-1) : 0;
                                    counter_word_rcv <= counter_word_rcv + 1;
                                    word_done <= 1'b1;
                                    processing_word <= 1'b0;
                                end else begin
                                    bit_counter <= invert_data_order ? (bit_counter - 1) : (bit_counter + 1);
                                    word_done <= 1'b0;
                                    processing_word <= 1'b1;
                                end
                            end
                        end
                    end else begin
                        word_done <= 1'b0;
                        spi_status <= cycle_wait;
                    end
            end
            finish: begin
                activate_cs <= 1'b0;
                activate_sclk <= 1'b0;
                transaction_done <= 1'b1;
                spi_status <= idle;
            end
            default: begin
                spi_status <= idle;
            end
        endcase
        /* verilator lint_off CASEINCOMPLETE */
    end
end


endmodule
