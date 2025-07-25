//----------------------------------------------------------------------------
//                                                                          --
//                         Module Declaration                               --
//                                                                          --
//----------------------------------------------------------------------------
`include "src/spi_controller.v"
`include "src/input_timer.v"
`include "src/clk_divider.v"

module top (
  // left side gpios
  output wire gpio_23,
  output wire gpio_25,
  output wire gpio_26,
  output wire gpio_27,
  output wire gpio_32,
  output wire gpio_35,
  output wire gpio_31,
  output wire gpio_37,
  output wire gpio_34,
  output wire gpio_43,
  output wire gpio_36,
  output wire gpio_42,
  output wire gpio_38,
  output wire gpio_28,
  // right side gpios
  output wire gpio_20,
  output wire gpio_10,
  output wire gpio_12,
  output wire gpio_21,
  output wire gpio_13,
  output wire gpio_19,
  output wire gpio_18,
  output wire gpio_11,
  output wire gpio_9,
  output wire gpio_6,
  output wire gpio_44,
  output wire gpio_4,
  output wire gpio_3,
  output wire gpio_48,
  input wire gpio_45,
  output wire gpio_47,
  input wire gpio_46,
  input wire gpio_2
);

//----------------------------------------------------------------------------
//                                                                          --
//                       Internal Oscillator                                --
//                                                                          --
//----------------------------------------------------------------------------
wire int_osc; // 12 MHz

SB_HFOSC u_SB_HFOSC (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(int_osc));

// 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12 MHz, 0b11 = 6 MHz
    defparam u_SB_HFOSC.CLKHF_DIV = "0b10";

//----------------------------------------------------------------------------
//                                                                          --
//                       SPI controller                                     --
//                                                                          --
//----------------------------------------------------------------------------
reg spi_clk;
reg copi;
wire pico;
reg cs;

reg [9:0] ch0_word;
reg [9:0] ch1_word;

reg valid;

spi_controller spi_ADC
    (
        .clk(int_osc),              // system clk
        .rst(1'b0),                 // reset
        .sclk_o(spi_clk),           // SPI clk out
        .cs_o(cs),                  // chip select out
        .data_o(copi),              // SPI data ouput line
        .data_i(pico),              // SPI data input line
        .ch0_word(ch0_word),        // data word to send
        .ch1_word(ch1_word),        // data word received 
        .valid(valid)               // data valid signal
    );

localparam [9:0] duty_offset = 0;
localparam [9:0] period_offset = 0;
localparam [9:0] duty_scale = 10'd1;
localparam [9:0] period_scale = 10'd1;

reg [9:0] duty;
reg [9:0] period_adc;

always @(posedge int_osc) begin
  if(valid) begin
    duty <= ch0_word*duty_scale + duty_offset;
    period_adc <= ch1_word*period_scale + period_offset;
  end
end

//----------------------------------------------------------------------------
//                                                                          --
//                       Input timer                                        --
//                                                                          --
//----------------------------------------------------------------------------
reg [9:0] period_timer;
wire timer_signal;

input_timer #(.DATA_WIDTH(10)) timer (.clk(int_osc), .rst(1'b0), .signal(timer_signal), .period(period_timer));

reg [9:0] period;
wire period_switch;
always @(posedge int_osc) begin
  if(period_switch) begin
    period <= period_timer;
  end else begin
    period <= period_adc;
  end
end

//----------------------------------------------------------------------------
//                                                                          --
//                       Clock dividers                                     --
//                                                                          --
//----------------------------------------------------------------------------
reg mul_16;
reg mul_8;
reg mul_5;
reg mul_4;
reg mul_3;
reg mul_2;
reg mul_1;
reg div_2;
reg div_3;
reg div_4;
reg div_5;
reg div_8;
reg div_16;

clk_divider #(.DATA_WIDTH(10)) clk_div 
    (
        .rst(1'b0), 
        .int_osc(int_osc), 
        .master_period(period), 
        .duty_cycle(duty),  
        .mul_16(mul_16), 
        .mul_8(mul_8),
        .mul_5(mul_5), 
        .mul_4(mul_4), 
        .mul_3(mul_3), 
        .mul_2(mul_2),
        .mul_1(mul_1), 
        .div_2(div_2), 
        .div_3(div_3), 
        .div_4(div_4), 
        .div_5(div_5), 
        .div_8(div_8), 
        .div_16(div_16)
    );

//----------------------------------------------------------------------------
//                                                                          --
//                       GPIOs                                              --
//                                                                          --
//----------------------------------------------------------------------------
// clk dividers
assign gpio_23 = mul_16; // x16 logic
assign gpio_25 = mul_16; // x16 led
assign gpio_26 = mul_8; // x8 logic
assign gpio_27 = mul_8; // x8 led
assign gpio_32 = mul_5; // x5 logic
assign gpio_35 = mul_5; // x5 led
assign gpio_31 = mul_4; // x4 logic
assign gpio_37 = mul_4; // x4 led
assign gpio_34 = mul_3; // x3 logic
assign gpio_43 = mul_3; // x3 led
assign gpio_36 = mul_2; // x2 logic
assign gpio_42 = mul_2; // x2 led
assign gpio_38 = mul_1; // x1 logic
assign gpio_28 = mul_1; // x1 led
assign gpio_20 = div_2; // /2 logic
assign gpio_10 = div_2; // /2 led
assign gpio_12 = div_3; // /3 logic
assign gpio_21 = div_3; // /3 led
assign gpio_13 = div_4; // /4 logic
assign gpio_19 = div_4; // /4 led
assign gpio_18 = div_5; // /5 logic
assign gpio_11 = div_5; // /5 led
assign gpio_9 = div_8; // /8 logic
assign gpio_6 = div_8; // /8 led
assign gpio_44 = div_16; // /16 logic
assign gpio_4 = div_16; // /16 led
// spi
assign gpio_3 = spi_clk;
assign gpio_48 = copi;
assign pico = gpio_45;
assign gpio_47 = cs;
// input timer
assign timer_signal = gpio_46;
assign period_switch = gpio_2;

endmodule
