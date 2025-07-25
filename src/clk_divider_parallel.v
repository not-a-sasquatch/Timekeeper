//----------------------------------------------------------------------------
//                                                                          --
//                         clk_divider.v                                    --
//                                                                          --
// Calculates various digital output signals with periods calculated from   --
// master input period and input duty_cycle                                 --
// Outputs: x1, x2, x3, x4, x5, x8, x16, /2, /3, /4, /5, /8, /16            --
// Author: Connie S.                                                        --
//                                                                          --
//----------------------------------------------------------------------------
`include "divuint_if.v"
`include "muluint_if.v"

module clk_divider_parallel #(parameter DATA_WIDTH=10) (
    // inputs
    input wire rst,
    input wire int_osc,
    input wire [DATA_WIDTH-1:0] master_period,
    input wire [DATA_WIDTH-1:0] duty_cycle,

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

// Period registers
reg [DATA_WIDTH-1:0] mul_16_period;
reg [DATA_WIDTH-1:0] mul_8_period;
reg [DATA_WIDTH-1:0] mul_5_period;
reg [DATA_WIDTH-1:0] mul_4_period;
reg [DATA_WIDTH-1:0] mul_3_period;
reg [DATA_WIDTH-1:0] mul_2_period;
reg [DATA_WIDTH-1:0] mul_1_period;
reg [DATA_WIDTH-1:0] div_2_period;
reg [DATA_WIDTH-1:0] div_3_period;
reg [DATA_WIDTH-1:0] div_4_period;
reg [DATA_WIDTH-1:0] div_5_period;
reg [DATA_WIDTH-1:0] div_8_period;
reg [DATA_WIDTH-1:0] div_16_period;

// Period registers for synchronization
reg [DATA_WIDTH-1:0] mul_16_period_sync;
reg [DATA_WIDTH-1:0] mul_8_period_sync;
reg [DATA_WIDTH-1:0] mul_5_period_sync;
reg [DATA_WIDTH-1:0] mul_4_period_sync;
reg [DATA_WIDTH-1:0] mul_3_period_sync;
reg [DATA_WIDTH-1:0] mul_2_period_sync;
reg [DATA_WIDTH-1:0] mul_1_period_sync;
reg [DATA_WIDTH-1:0] div_2_period_sync;
reg [DATA_WIDTH-1:0] div_3_period_sync;
reg [DATA_WIDTH-1:0] div_4_period_sync;
reg [DATA_WIDTH-1:0] div_5_period_sync;
reg [DATA_WIDTH-1:0] div_8_period_sync;
reg [DATA_WIDTH-1:0] div_16_period_sync;

reg [DATA_WIDTH-1:0] mul_16_period_sync_temp;
reg [DATA_WIDTH-1:0] mul_8_period_sync_temp;
reg [DATA_WIDTH-1:0] mul_5_period_sync_temp;
reg [DATA_WIDTH-1:0] mul_4_period_sync_temp;
reg [DATA_WIDTH-1:0] mul_3_period_sync_temp;
reg [DATA_WIDTH-1:0] mul_2_period_sync_temp;

// Duty period registers
reg [DATA_WIDTH-1:0] mul_16_duty;
reg [DATA_WIDTH-1:0] mul_8_duty;
reg [DATA_WIDTH-1:0] mul_5_duty;
reg [DATA_WIDTH-1:0] mul_4_duty;
reg [DATA_WIDTH-1:0] mul_3_duty;
reg [DATA_WIDTH-1:0] mul_2_duty;
reg [DATA_WIDTH-1:0] mul_1_duty;
reg [DATA_WIDTH-1:0] div_2_duty;
reg [DATA_WIDTH-1:0] div_3_duty;
reg [DATA_WIDTH-1:0] div_4_duty;
reg [DATA_WIDTH-1:0] div_5_duty;
reg [DATA_WIDTH-1:0] div_8_duty;
reg [DATA_WIDTH-1:0] div_16_duty;

// Duty period registers for synchronization
reg [DATA_WIDTH-1:0] mul_16_duty_sync;
reg [DATA_WIDTH-1:0] mul_8_duty_sync;
reg [DATA_WIDTH-1:0] mul_5_duty_sync;
reg [DATA_WIDTH-1:0] mul_4_duty_sync;
reg [DATA_WIDTH-1:0] mul_3_duty_sync;
reg [DATA_WIDTH-1:0] mul_2_duty_sync;
reg [DATA_WIDTH-1:0] mul_1_duty_sync;
reg [DATA_WIDTH-1:0] div_2_duty_sync;
reg [DATA_WIDTH-1:0] div_3_duty_sync;
reg [DATA_WIDTH-1:0] div_4_duty_sync;
reg [DATA_WIDTH-1:0] div_5_duty_sync;
reg [DATA_WIDTH-1:0] div_8_duty_sync;
reg [DATA_WIDTH-1:0] div_16_duty_sync;

// Frequency counters
reg [DATA_WIDTH-1:0] mul_16_counter;
reg [DATA_WIDTH-1:0] mul_8_counter;
reg [DATA_WIDTH-1:0] mul_5_counter;
reg [DATA_WIDTH-1:0] mul_4_counter;
reg [DATA_WIDTH-1:0] mul_3_counter;
reg [DATA_WIDTH-1:0] mul_2_counter;
reg [DATA_WIDTH-1:0] mul_1_counter;
reg [DATA_WIDTH-1:0] div_2_counter;
reg [DATA_WIDTH-1:0] div_3_counter;
reg [DATA_WIDTH-1:0] div_4_counter;
reg [DATA_WIDTH-1:0] div_5_counter;
reg [DATA_WIDTH-1:0] div_8_counter;
reg [DATA_WIDTH-1:0] div_16_counter;

// Garbage registers for padding division
/* verilator lint_off UNUSEDSIGNAL */
reg [DATA_WIDTH-1:0] mul_16_garbage;
reg [DATA_WIDTH-1:0] mul_8_garbage;
reg [DATA_WIDTH-1:0] mul_5_garbage;
reg [DATA_WIDTH-1:0] mul_4_garbage;
reg [DATA_WIDTH-1:0] mul_3_garbage;
reg [DATA_WIDTH-1:0] mul_2_garbage;
reg [DATA_WIDTH-1:0] mul_1_garbage;
reg [DATA_WIDTH-1:0] div_2_garbage;
reg [DATA_WIDTH-1:0] div_3_garbage;
reg [DATA_WIDTH-1:0] div_4_garbage;
reg [DATA_WIDTH-1:0] div_5_garbage;
reg [DATA_WIDTH-1:0] div_8_garbage;
reg [DATA_WIDTH-1:0] div_16_garbage;
/* verilator lint_off UNUSEDSIGNAL */

// Period registers
reg [2*DATA_WIDTH-1:0] mul_16_period_scale;
reg [2*DATA_WIDTH-1:0] mul_8_period_scale;
reg [2*DATA_WIDTH-1:0] mul_5_period_scale;
reg [2*DATA_WIDTH-1:0] mul_4_period_scale;
reg [2*DATA_WIDTH-1:0] mul_3_period_scale;
reg [2*DATA_WIDTH-1:0] mul_2_period_scale;
reg [2*DATA_WIDTH-1:0] mul_1_period_scale;
reg [2*DATA_WIDTH-1:0] div_2_period_scale;
reg [2*DATA_WIDTH-1:0] div_3_period_scale;
reg [2*DATA_WIDTH-1:0] div_4_period_scale;
reg [2*DATA_WIDTH-1:0] div_5_period_scale;
reg [2*DATA_WIDTH-1:0] div_8_period_scale;
reg [2*DATA_WIDTH-1:0] div_16_period_scale;

reg [2*DATA_WIDTH-1:0] mul_16_period_temp;
reg [2*DATA_WIDTH-1:0] mul_8_period_temp;
reg [2*DATA_WIDTH-1:0] mul_5_period_temp;
reg [2*DATA_WIDTH-1:0] mul_4_period_temp;
reg [2*DATA_WIDTH-1:0] mul_3_period_temp;
reg [2*DATA_WIDTH-1:0] mul_2_period_temp;
reg [2*DATA_WIDTH-1:0] mul_1_period_temp;
reg [2*DATA_WIDTH-1:0] div_2_period_temp;
reg [2*DATA_WIDTH-1:0] div_3_period_temp;
reg [2*DATA_WIDTH-1:0] div_4_period_temp;
reg [2*DATA_WIDTH-1:0] div_5_period_temp;
reg [2*DATA_WIDTH-1:0] div_8_period_temp;
reg [2*DATA_WIDTH-1:0] div_16_period_temp;

// Repetition counters for synchronization
reg [6:0] mul_16_reps;
reg [6:0] mul_8_reps;
reg [6:0] mul_5_reps;
reg [6:0] mul_4_reps;
reg [6:0] mul_3_reps;
reg [6:0] mul_2_reps;

// Additional registers for synchronization between divider circuitry
// Divider #1 synchronization
reg div_2_sync1;
reg div_3_sync1;
reg div_4_sync1;
reg div_5_sync1;
reg div_8_sync1;
reg div_16_sync1;


reg mul_16_valid1;
reg mul_8_valid1;
reg mul_5_valid1;
reg mul_4_valid1;
reg mul_3_valid1;
reg mul_2_valid1;
reg div_2_valid1;
reg div_3_valid1;
reg div_4_valid1;
reg div_5_valid1;
reg div_8_valid1;
reg div_16_valid1;

// Divider #2 synchronization
reg mul_16_sync2;
reg mul_8_sync2;
reg mul_5_sync2;
reg mul_4_sync2;
reg mul_3_sync2;
reg mul_2_sync2;
reg mul_1_sync2;
reg div_2_sync2;
reg div_3_sync2;
reg div_4_sync2;
reg div_5_sync2;
reg div_8_sync2;
reg div_16_sync2;

reg mul_16_valid2;
reg mul_8_valid2;
reg mul_5_valid2;
reg mul_4_valid2;
reg mul_3_valid2;
reg mul_2_valid2;
reg mul_1_valid2;
reg div_2_valid2;
reg div_3_valid2;
reg div_4_valid2;
reg div_5_valid2;
reg div_8_valid2;
reg div_16_valid2;

reg mul_16_valid3;
reg mul_8_valid3;
reg mul_5_valid3;
reg mul_4_valid3;
reg mul_3_valid3;
reg mul_2_valid3;
reg mul_1_valid3;
reg div_2_valid3;
reg div_3_valid3;
reg div_4_valid3;
reg div_5_valid3;
reg div_8_valid3;
reg div_16_valid3;

initial begin
    mul_16 = 0;
    mul_8 = 0;
    mul_5 = 0;
    mul_4 = 0;
    mul_3 = 0;
    mul_2 = 0;
    mul_1 = 0;
    div_2 = 0;
    div_3 = 0;
    div_4 = 0;
    div_5 = 0;
    div_8 = 0;
    div_16 = 0;

    mul_16_period = {(DATA_WIDTH){1'b1}};
    mul_8_period = {(DATA_WIDTH){1'b1}};
    mul_5_period = {(DATA_WIDTH){1'b1}};
    mul_4_period = {(DATA_WIDTH){1'b1}};
    mul_3_period = {(DATA_WIDTH){1'b1}};
    mul_2_period = {(DATA_WIDTH){1'b1}};
    mul_1_period = {(DATA_WIDTH){1'b1}};
    div_2_period = {(DATA_WIDTH){1'b1}};
    div_3_period = {(DATA_WIDTH){1'b1}};
    div_4_period = {(DATA_WIDTH){1'b1}};
    div_5_period = {(DATA_WIDTH){1'b1}};
    div_8_period = {(DATA_WIDTH){1'b1}};
    div_16_period = {(DATA_WIDTH){1'b1}};

    // mul_16_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_8_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_5_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_4_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_3_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_2_period_sync = {(DATA_WIDTH){1'b1}};
    // mul_1_period_sync = {(DATA_WIDTH){1'b1}};
    // div_2_period_sync = {(DATA_WIDTH){1'b1}};
    // div_3_period_sync = {(DATA_WIDTH){1'b1}};
    // div_4_period_sync = {(DATA_WIDTH){1'b1}};
    // div_5_period_sync = {(DATA_WIDTH){1'b1}};
    // div_8_period_sync = {(DATA_WIDTH){1'b1}};
    // div_16_period_sync = {(DATA_WIDTH){1'b1}};

    mul_16_duty = 0;
    mul_8_duty = 0;
    mul_5_duty = 0;
    mul_4_duty = 0;
    mul_3_duty = 0;
    mul_2_duty = 0;
    mul_1_duty = 0;
    div_2_duty = 0;
    div_3_duty = 0;
    div_4_duty = 0;
    div_5_duty = 0;
    div_8_duty = 0;
    div_16_duty = 0;

    // mul_16_duty_sync = 0;
    // mul_8_duty_sync = 0;
    // mul_5_duty_sync = 0;
    // mul_4_duty_sync = 0;
    // mul_3_duty_sync = 0;
    // mul_2_duty_sync = 0;
    // mul_1_duty_sync = 0;
    // div_2_duty_sync = 0;
    // div_3_duty_sync = 0;
    // div_4_duty_sync = 0;
    // div_5_duty_sync = 0;
    // div_8_duty_sync = 0;
    // div_16_duty_sync = 0;


    mul_16_counter = 0;
    mul_8_counter = 0;
    mul_5_counter = 0;
    mul_4_counter = 0;
    mul_3_counter = 0;
    mul_2_counter = 0;
    mul_1_counter = 0;
    div_2_counter = 0;
    div_3_counter = 0;
    div_4_counter = 0;
    div_5_counter = 0;
    div_8_counter = 0;
    div_16_counter = 0;

    // mul_16_garbage = 0;
    // mul_8_garbage = 0;
    // mul_5_garbage = 0;
    // mul_4_garbage = 0;
    // mul_3_garbage = 0;
    // mul_2_garbage = 0;
    // mul_1_garbage = 0;
    // div_2_garbage = 0;
    // div_3_garbage = 0;
    // div_4_garbage = 0;
    // div_5_garbage = 0;
    // div_8_garbage = 0;
    // div_16_garbage = 0;

    mul_16_reps = 0;
    mul_8_reps = 0;
    mul_5_reps = 0;
    mul_4_reps = 0;
    mul_3_reps = 0;
    mul_2_reps = 0;

    div_2_sync1 = 0;
    div_3_sync1 = 0;
    div_4_sync1 = 0;
    div_5_sync1 = 0;
    div_8_sync1 = 0;
    div_16_sync1 = 0;

    mul_16_sync2 = 0;
    mul_8_sync2 = 0;
    mul_5_sync2 = 0;
    mul_4_sync2 = 0;
    mul_3_sync2 = 0;
    mul_2_sync2 = 0;
    mul_1_sync2 = 0;
    div_2_sync2 = 0;
    div_3_sync2 = 0;
    div_4_sync2 = 0;
    div_5_sync2 = 0;
    div_8_sync2 = 0;
    div_16_sync2 = 0;
end

// Update periods
always @(*) begin
    if(sync_valid1) begin
        mul_16_period_sync <= mul_16_period_sync_temp;
        mul_8_period_sync <= mul_8_period_sync_temp;
        mul_5_period_sync <= mul_5_period_sync_temp;
        mul_4_period_sync <= mul_4_period_sync_temp;
        mul_3_period_sync <= mul_3_period_sync_temp;
        mul_2_period_sync <= mul_2_period_sync_temp;
    end
    mul_1_period_sync <= master_period;

    if(sync_valid3) begin
        mul_16_period_scale <= mul_16_period_temp;
        mul_8_period_scale <= mul_8_period_temp;
        mul_5_period_scale <= mul_5_period_temp;
        mul_4_period_scale <= mul_4_period_temp;
        mul_3_period_scale <= mul_3_period_temp;
        mul_2_period_scale <= mul_2_period_temp;
        mul_1_period_scale <= mul_1_period_temp;
        div_2_period_scale <= div_2_period_temp;
        div_3_period_scale <= div_3_period_temp;
        div_4_period_scale <= div_4_period_temp;
        div_5_period_scale <= div_5_period_temp;
        div_8_period_scale <= div_8_period_temp;
        div_16_period_scale <= div_16_period_temp;
    end
    
end


// Multiplier #1 - calculate multiplication periods        // (DATA_WIDTH)'('d16)
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_2(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d2), .result(mul_2_period_sync_temp), .valid_o(mul_2_valid1));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_3(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d3), .result(mul_3_period_sync_temp), .valid_o(mul_3_valid1));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_4(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d4), .result(mul_4_period_sync_temp), .valid_o(mul_4_valid1));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_5(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d5), .result(mul_5_period_sync_temp), .valid_o(mul_5_valid1));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_8(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d6), .result(mul_8_period_sync_temp), .valid_o(mul_8_valid1));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_16(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d16), .result(mul_16_period_sync_temp), .valid_o(mul_16_valid1));

// Multiplier #1 syncronization
reg sync_valid1;
always @(*) begin
    sync_valid1 <= mul_2_valid1 && mul_3_valid1 && mul_4_valid1 && mul_5_valid1 && mul_8_valid1 && mul_16_valid1;
end

// Divider #1 - calculate division periods        // (DATA_WIDTH)'('d16)
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_2(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d2), .result(div_2_period_sync), .valid_o(div_2_valid1));
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_3(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d3), .result(div_3_period_sync), .valid_o(div_3_valid1));
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_4(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d4), .result(div_4_period_sync), .valid_o(div_4_valid1));
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_5(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d5), .result(div_5_period_sync), .valid_o(div_5_valid1));
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_8(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d6), .result(div_8_period_sync), .valid_o(div_8_valid1));
divuint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_16(.rst(rst), .clk(int_osc), .input0(master_period), .input1('d16), .result(div_16_period_sync), .valid_o(div_16_valid1));

// Multiplier #2 - scale all periods by duty cycle
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_16_period(.rst(rst), .clk(int_osc), .input0(mul_16_period), .input1(duty_cycle), .result(mul_16_period_temp), .valid_o(mul_16_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_8_period(.rst(rst), .clk(int_osc), .input0(mul_8_period), .input1(duty_cycle), .result(mul_8_period_temp), .valid_o(mul_8_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_5_period(.rst(rst), .clk(int_osc), .input0(mul_5_period), .input1(duty_cycle), .result(mul_5_period_temp), .valid_o(mul_5_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_4_period(.rst(rst), .clk(int_osc), .input0(mul_4_period), .input1(duty_cycle), .result(mul_4_period_temp), .valid_o(mul_4_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_3_period(.rst(rst), .clk(int_osc), .input0(mul_3_period), .input1(duty_cycle), .result(mul_3_period_temp), .valid_o(mul_3_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_2_period(.rst(rst), .clk(int_osc), .input0(mul_2_period), .input1(duty_cycle), .result(mul_2_period_temp), .valid_o(mul_2_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) multiplier_1_period(.rst(rst), .clk(int_osc), .input0(mul_1_period), .input1(duty_cycle), .result(mul_1_period_temp), .valid_o(mul_1_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_2_period(.rst(rst), .clk(int_osc), .input0(div_2_period), .input1(duty_cycle), .result(div_2_period_temp), .valid_o(div_2_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_3_period(.rst(rst), .clk(int_osc), .input0(div_3_period), .input1(duty_cycle), .result(div_3_period_temp2), .valid_o(div_3_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_4_period(.rst(rst), .clk(int_osc), .input0(div_4_period), .input1(duty_cycle), .result(div_4_period_temp), .valid_o(div_4_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_5_period(.rst(rst), .clk(int_osc), .input0(div_5_period), .input1(duty_cycle), .result(div_5_period_temp), .valid_o(div_5_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_8_period(.rst(rst), .clk(int_osc), .input0(div_8_period), .input1(duty_cycle), .result(div_8_period_temp), .valid_o(div_8_valid3));
muluint_if #(.DATA_WIDTH(DATA_WIDTH)) divider_16_period(.rst(rst), .clk(int_osc), .input0(div_16_period), .input1(duty_cycle), .result(div_16_period_temp), .valid_o(div_16_valid3));

// Multiplier #2 syncronization
reg sync_valid3;
always @(*) begin
    sync_valid3 <= mul_2_valid3 && mul_3_valid3 && mul_4_valid3 && mul_5_valid3 && mul_8_valid3 && mul_16_valid3;
end

// Divider #1 syncronization
reg sync1;
always @(*) begin
    sync1 <= div_2_sync1 && div_3_sync1 && div_4_sync1 && div_5_sync1 && div_8_sync1 && div_16_sync1;
end
// assign sync1 = div_2_sync1 && div_3_sync1 && div_4_sync1 && div_5_sync1 && div_8_sync1 && div_16_sync1;
always @(posedge int_osc or posedge rst) begin
    if(rst) begin
        div_2_sync1 <= 0;
        div_3_sync1 <= 0;
        div_4_sync1 <= 0;
        div_5_sync1 <= 0;
        div_8_sync1 <= 0;
        div_16_sync1 <= 0;
    end else begin
        if(div_2_valid1) div_2_sync1 <= 1;
        if(div_3_valid1) div_3_sync1 <= 1;
        if(div_4_valid1) div_4_sync1 <= 1;
        if(div_5_valid1) div_5_sync1 <= 1;
        if(div_8_valid1) div_8_sync1 <= 1;
        if(div_16_valid1) div_16_sync1 <= 1;

        if(sync1) begin
            div_2_sync1 <= 0;
            div_3_sync1 <= 0;
            div_4_sync1 <= 0;
            div_5_sync1 <= 0;
            div_8_sync1 <= 0;
            div_16_sync1 <= 0;

            mul_16_period <= mul_16_period_sync;
            mul_8_period <= mul_8_period_sync;
            mul_5_period <= mul_5_period_sync;
            mul_4_period <= mul_4_period_sync;
            mul_3_period <= mul_3_period_sync;
            mul_2_period <= mul_2_period_sync;
            mul_1_period <= mul_1_period_sync;
            div_2_period <= div_2_period_sync;
            div_3_period <= div_3_period_sync;
            div_4_period <= div_4_period_sync;
            div_5_period <= div_5_period_sync;
            div_8_period <= div_8_period_sync;
            div_16_period <= div_16_period_sync;
        end
    end
end

// Divider #2 - calculate duty cycles
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_16_duty(.rst(rst), .clk(int_osc), .input0(mul_16_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_16_garbage, mul_16_duty_sync}), .valid_o(mul_16_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_8_duty(.rst(rst), .clk(int_osc), .input0(mul_8_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_8_garbage, mul_8_duty_sync}), .valid_o(mul_8_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_5_duty(.rst(rst), .clk(int_osc), .input0(mul_5_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_5_garbage, mul_5_duty_sync}), .valid_o(mul_5_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_4_duty(.rst(rst), .clk(int_osc), .input0(mul_4_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_4_garbage, mul_4_duty_sync}), .valid_o(mul_4_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_3_duty(.rst(rst), .clk(int_osc), .input0(mul_3_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_3_garbage, mul_3_duty_sync}), .valid_o(mul_3_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_2_duty(.rst(rst), .clk(int_osc), .input0(mul_2_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_2_garbage, mul_2_duty_sync}), .valid_o(mul_2_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_mul_1_duty(.rst(rst), .clk(int_osc), .input0(mul_1_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({mul_1_garbage, mul_1_duty_sync}), .valid_o(mul_1_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_2_duty(.rst(rst), .clk(int_osc), .input0(div_2_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_2_garbage, div_2_duty_sync}), .valid_o(div_2_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_3_duty(.rst(rst), .clk(int_osc), .input0(div_3_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_3_garbage, div_3_duty_sync}), .valid_o(div_3_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_4_duty(.rst(rst), .clk(int_osc), .input0(div_4_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_4_garbage, div_4_duty_sync}), .valid_o(div_4_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_5_duty(.rst(rst), .clk(int_osc), .input0(div_5_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_5_garbage, div_5_duty_sync}), .valid_o(div_5_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_8_duty(.rst(rst), .clk(int_osc), .input0(div_8_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_8_garbage, div_8_duty_sync}), .valid_o(div_8_valid2));
divuint_if #(.DATA_WIDTH(2*DATA_WIDTH)) divider_div_16_duty(.rst(rst), .clk(int_osc), .input0(div_16_period_scale), .input1({{(DATA_WIDTH){1'b0}},{(DATA_WIDTH){1'b1}}}), .result({div_16_garbage, div_16_duty_sync}), .valid_o(div_16_valid2));

// Divider #2 syncronization
reg sync2;
always @(*) begin
    sync2 <= mul_16_sync2 && mul_8_sync2 && mul_5_sync2 && mul_4_sync2 && mul_3_sync2 && mul_2_sync2 && mul_1_sync2 && div_2_sync2 && div_3_sync2 && div_4_sync2 && div_5_sync2 && div_8_sync2 && div_16_sync2;
end
// assign sync2 = mul_16_sync2 && mul_8_sync2 && mul_5_sync2 && mul_4_sync2 && mul_3_sync2 && mul_2_sync2 && mul_1_sync2 && div_2_sync2 && div_3_sync2 && div_4_sync2 && div_5_sync2 && div_8_sync2 && div_16_sync2;
always @(posedge int_osc or posedge rst) begin
    if(rst) begin
        mul_16_sync2 <= 0;
        mul_8_sync2 <= 0;
        mul_5_sync2 <= 0;
        mul_4_sync2 <= 0;
        mul_3_sync2 <= 0;
        mul_2_sync2 <= 0;
        mul_1_sync2 <= 0;
        div_2_sync2 <= 0;
        div_3_sync2 <= 0;
        div_4_sync2 <= 0;
        div_5_sync2 <= 0;
        div_8_sync2 <= 0;
        div_16_sync2 <= 0;
    end else begin
        if(mul_16_valid2) mul_16_sync2 <= 1;
        if(mul_8_valid2) mul_8_sync2 <= 1;
        if(mul_5_valid2) mul_5_sync2 <= 1;
        if(mul_4_valid2) mul_4_sync2 <= 1;
        if(mul_3_valid2) mul_3_sync2 <= 1;
        if(mul_2_valid2) mul_2_sync2 <= 1;
        if(mul_1_valid2) mul_1_sync2 <= 1;
        if(div_2_valid2) div_2_sync2 <= 1;
        if(div_3_valid2) div_3_sync2 <= 1;
        if(div_4_valid2) div_4_sync2 <= 1;
        if(div_5_valid2) div_5_sync2 <= 1;
        if(div_8_valid2) div_8_sync2 <= 1;
        if(div_16_valid2) div_16_sync2 <= 1;

        if(sync2) begin
            mul_16_sync2 <= 0;
            mul_8_sync2 <= 0;
            mul_5_sync2 <= 0;
            mul_4_sync2 <= 0;
            mul_3_sync2 <= 0;
            mul_2_sync2 <= 0;
            mul_1_sync2 <= 0;
            div_2_sync2 <= 0;
            div_3_sync2 <= 0;
            div_4_sync2 <= 0;
            div_5_sync2 <= 0;
            div_8_sync2 <= 0;
            div_16_sync2 <= 0;

            mul_16_duty <= mul_16_duty_sync;
            mul_8_duty <= mul_8_duty_sync;
            mul_5_duty <= mul_5_duty_sync;
            mul_4_duty <= mul_4_duty_sync;
            mul_3_duty <= mul_3_duty_sync;
            mul_2_duty <= mul_2_duty_sync;
            mul_1_duty <= mul_1_duty_sync;
            div_2_duty <= div_2_duty_sync;
            div_3_duty <= div_3_duty_sync;
            div_4_duty <= div_4_duty_sync;
            div_5_duty <= div_5_duty_sync;
            div_8_duty <= div_8_duty_sync;
            div_16_duty <= div_16_duty_sync;
        end
    end
end

// Update frequency counters
always @(posedge int_osc) begin
    // Mul 16
    if(rst) begin
        mul_16 <= 0;
        mul_16_counter <= 0;
    end else if(mul_16_counter >= mul_16_period) begin
        mul_16 <= 1'b1;
        mul_16_counter <= 0;
        mul_16_reps <= 0;
    end else if(mul_16_counter < mul_16_duty) begin
        mul_16 <= 1'b1;
        mul_16_counter <= mul_16_counter + 1'b1;
    end else begin
        mul_16 <= 0;
        mul_16_counter <= mul_16_counter + 1'b1;
    end
    // Mul 8
    if(rst) begin
        mul_8 <= 0;
        mul_8_counter <= 0;
    end else if(mul_8_counter >= mul_8_period) begin
        mul_8 <= 1'b1;
        mul_8_counter <= 0;
        mul_8_reps <= 0;
    end else if(mul_8_counter < mul_8_duty) begin
        mul_8 <= 1'b1;
        mul_8_counter <= mul_8_counter + 1'b1;
    end else begin
        mul_8 <= 0;
        mul_8_counter <= mul_8_counter + 1'b1;
    end
    // Mul 5
    if(rst) begin
        mul_5 <= 0;
        mul_5_counter <= 0;
    end else if(mul_5_counter >= mul_5_period) begin
        mul_5 <= 1'b1;
        mul_5_counter <= 0;
        mul_5_reps <= 0;
    end else if(mul_5_counter < mul_5_duty) begin
        mul_5 <= 1'b1;
        mul_5_counter <= mul_5_counter + 1'b1;
    end else begin
        mul_5 <= 0;
        mul_5_counter <= mul_5_counter + 1'b1;
    end
    // Mul 4
    if(rst) begin
        mul_4 <= 0;
        mul_4_counter <= 0;
    end else if(mul_4_counter >= mul_4_period) begin
        mul_4 <= 1'b1;
        mul_4_counter <= 0;
        mul_4_reps <= 0;
    end else if(mul_4_counter < mul_4_duty) begin
        mul_4 <= 1'b1;
        mul_4_counter <= mul_4_counter + 1'b1;
    end else begin
        mul_4 <= 0;
        mul_4_counter <= mul_4_counter + 1'b1;
    end
    // Mul 3
    if(rst) begin
        mul_3 <= 0;
        mul_3_counter <= 0;
    end else if(mul_3_counter >= mul_3_period) begin
        mul_3 <= 1'b1;
        mul_3_counter <= 0;
        mul_3_reps <= 0;
    end else if(mul_3_counter < mul_3_duty) begin
        mul_3 <= 1'b1;
        mul_3_counter <= mul_3_counter + 1'b1;
    end else begin
        mul_3 <= 0;
        mul_3_counter <= mul_3_counter + 1'b1;
    end
    // Mul 2
    if(rst) begin
        mul_2 <= 0;
        mul_2_counter <= 0;
    end else if(mul_2_counter >= mul_2_period) begin
        mul_2 <= 1'b1;
        mul_2_counter <= 0;
        mul_2_reps <= 0;
    end else if(mul_2_counter < mul_2_duty) begin
        mul_2 <= 1'b1;
        mul_2_counter <= mul_2_counter + 1'b1;
    end else begin
        mul_2 <= 0;
        mul_2_counter <= mul_2_counter + 1'b1;
    end
    // Mul 1 and div's
    if(rst) begin
        mul_1 <= 0;
        mul_1_counter <= 0;
        div_2 <= 0;
        div_2_counter <= 0;
        div_3 <= 0;
        div_3_counter <= 0;
        div_4 <= 0;
        div_4_counter <= 0;
        div_5 <= 0;
        div_5_counter <= 0;
        div_8 <= 0;
        div_8_counter <= 0;
        div_16 <= 0;
        div_16_counter <= 0;
    end else if(mul_1_counter >= mul_1_period) begin
        if(mul_16_reps >= 16) begin
            mul_16 <= 1'b1;
            mul_16_counter <= 0;
            mul_16_reps <= 0;
        end else begin
            mul_16_reps <= mul_16_reps + 1;
        end
        if(mul_8_reps >= 8) begin
            mul_8 <= 1'b1;
            mul_8_counter <= 0;
            mul_8_reps <= 0;
        end else begin
            mul_8_reps <= mul_8_reps + 1;
        end
        if(mul_5_reps >= 5) begin
            mul_5 <= 1'b1;
            mul_5_counter <= 0;
            mul_5_reps <= 0;
        end else begin
            mul_5_reps <= mul_5_reps + 1;
        end
        if(mul_4_reps >= 4) begin
            mul_4 <= 1'b1;
            mul_4_counter <= 0;
            mul_4_reps <= 0;
        end else begin
            mul_4_reps <= mul_4_reps + 1;
        end
        if(mul_3_reps >= 3) begin
            mul_3 <= 1'b1;
            mul_3_counter <= 0;
            mul_3_reps <= 0;
        end else begin
            mul_3_reps <= mul_3_reps + 1;
        end
        if(mul_2_reps >= 2) begin
            mul_2 <= 1'b1;
            mul_2_counter <= 0;
            mul_2_reps <= 0;
        end else begin
            mul_2_reps <= mul_2_reps + 1;
        end
        mul_1 <= 1'b1;
        mul_1_counter <= 0;
        div_2 <= 1'b1;
        div_2_counter <= 0;
        div_3 <= 1'b1;
        div_3_counter <= 0;
        div_4 <= 1'b1;
        div_4_counter <= 0;
        div_5 <= 1'b1;
        div_5_counter <= 0;
        div_8 <= 1'b1;
        div_8_counter <= 0;
        div_16 <= 1'b1;
        div_16_counter <= 0;
    end else begin
        if(mul_1_counter < mul_1_duty) begin
            mul_1 <= 1'b1;
            mul_1_counter <= mul_1_counter + 1'b1;
        end else begin
            mul_1 <= 0;
            mul_1_counter <= mul_1_counter + 1'b1;
        end
        // Div 2
        if(div_2_counter >= div_2_period) begin
            div_2 <= 1'b1;
            div_2_counter <= 0;
        end else if(div_2_counter < div_2_duty) begin
            div_2 <= 1'b1;
            div_2_counter <= div_2_counter + 1'b1;
        end else begin
            div_2 <= 0;
            div_2_counter <= div_2_counter + 1'b1;
        end
        // Div 3
        if(div_3_counter >= div_3_period) begin
            div_3 <= 1'b1;
            div_3_counter <= 0;
        end else if(div_3_counter < div_3_duty) begin
            div_3 <= 1'b1;
            div_3_counter <= div_3_counter + 1'b1;
        end else begin
            div_3 <= 0;
            div_3_counter <= div_3_counter + 1'b1;
        end
        // Div 4
        if(div_4_counter >= div_4_period) begin
            div_4 <= 1'b1;
            div_4_counter <= 0;
        end else if(div_4_counter < div_4_duty) begin
            div_4 <= 1'b1;
            div_4_counter <= div_4_counter + 1'b1;
        end else begin
            div_4 <= 0;
            div_4_counter <= div_4_counter + 1'b1;
        end
        // Div 5
        if(div_5_counter >= div_5_period) begin
            div_5 <= 1'b1;
            div_5_counter <= 0;
        end else if(div_5_counter < div_5_duty) begin
            div_5 <= 1'b1;
            div_5_counter <= div_5_counter + 1'b1;
        end else begin
            div_5 <= 0;
            div_5_counter <= div_5_counter + 1'b1;
        end
        // Div 8
        if(div_8_counter >= div_8_period) begin
            div_8 <= 1'b1;
            div_8_counter <= 0;
        end else if(div_8_counter < div_8_duty) begin
            div_8 <= 1'b1;
            div_8_counter <= div_8_counter + 1'b1;
        end else begin
            div_8 <= 0;
            div_8_counter <= div_8_counter + 1'b1;
        end
        // Div 16
        if(div_16_counter >= div_16_period) begin
            div_16 <= 1'b1;
            div_16_counter <= 0;
        end else if(div_16_counter < div_16_duty) begin
            div_16 <= 1'b1;
            div_16_counter <= div_16_counter + 1'b1;
        end else begin
            div_16 <= 0;
            div_16_counter <= div_16_counter + 1'b1;
        end
    end
    
    // if(rst) begin
    //     mul_1 <= 0;
    //     mul_1_counter <= 0;
    // end else if(mul_1_counter >= mul_1_period) begin
    //     if(mul_16_reps >= 16) begin
    //         mul_16 <= 1'b1;
    //         mul_16_counter <= 0;
    //         mul_16_reps <= 0;
    //     end else begin
    //         mul_16_reps <= mul_16_reps + 1;
    //     end
    //     if(mul_8_reps >= 8) begin
    //         mul_8 <= 1'b1;
    //         mul_8_counter <= 0;
    //         mul_8_reps <= 0;
    //     end else begin
    //         mul_8_reps <= mul_8_reps + 1;
    //     end
    //     if(mul_5_reps >= 5) begin
    //         mul_5 <= 1'b1;
    //         mul_5_counter <= 0;
    //         mul_5_reps <= 0;
    //     end else begin
    //         mul_5_reps <= mul_5_reps + 1;
    //     end
    //     if(mul_4_reps >= 4) begin
    //         mul_4 <= 1'b1;
    //         mul_4_counter <= 0;
    //         mul_4_reps <= 0;
    //     end else begin
    //         mul_4_reps <= mul_4_reps + 1;
    //     end
    //     if(mul_3_reps >= 3) begin
    //         mul_3 <= 1'b1;
    //         mul_3_counter <= 0;
    //         mul_3_reps <= 0;
    //     end else begin
    //         mul_3_reps <= mul_3_reps + 1;
    //     end
    //     if(mul_2_reps >= 2) begin
    //         mul_2 <= 1'b1;
    //         mul_2_counter <= 0;
    //         mul_2_reps <= 0;
    //     end else begin
    //         mul_2_reps <= mul_2_reps + 1;
    //     end
    //     mul_1 <= 1'b1;
    //     mul_1_counter <= 0;
    //     div_2 <= 1'b1;
    //     div_2_counter <= 0;
    //     div_3 <= 1'b1;
    //     div_3_counter <= 0;
    //     div_4 <= 1'b1;
    //     div_4_counter <= 0;
    //     div_5 <= 1'b1;
    //     div_5_counter <= 0;
    //     div_8 <= 1'b1;
    //     div_8_counter <= 0;
    //     div_16 <= 1'b1;
    //     div_16_counter <= 0;
    // end else if(mul_1_counter < mul_1_duty) begin
    //     mul_1 <= 1'b1;
    //     mul_1_counter <= mul_1_counter + 1'b1;
    // end else begin
    //     mul_1 <= 0;
    //     mul_1_counter <= mul_1_counter + 1'b1;
    // end
    // // Div 2
    // if(rst) begin
    //     div_2 <= 0;
    //     div_2_counter <= 0;
    // end else if(div_2_counter >= div_2_period) begin
    //     div_2 <= 1'b1;
    //     div_2_counter <= 0;
    // end else if(div_2_counter < div_2_duty) begin
    //     div_2 <= 1'b1;
    //     div_2_counter <= div_2_counter + 1'b1;
    // end else begin
    //     div_2 <= 0;
    //     div_2_counter <= div_2_counter + 1'b1;
    // end
    // // Div 3
    // if(rst) begin
    //     div_3 <= 0;
    //     div_3_counter <= 0;
    // end else if(div_3_counter >= div_3_period) begin
    //     div_3 <= 1'b1;
    //     div_3_counter <= 0;
    // end else if(div_3_counter < div_3_duty) begin
    //     div_3 <= 1'b1;
    //     div_3_counter <= div_3_counter + 1'b1;
    // end else begin
    //     div_3 <= 0;
    //     div_3_counter <= div_3_counter + 1'b1;
    // end
    // // Div 4
    // if(rst) begin
    //     div_4 <= 0;
    //     div_4_counter <= 0;
    // end else if(div_4_counter >= div_4_period) begin
    //     div_4 <= 1'b1;
    //     div_4_counter <= 0;
    // end else if(div_4_counter < div_4_duty) begin
    //     div_4 <= 1'b1;
    //     div_4_counter <= div_4_counter + 1'b1;
    // end else begin
    //     div_4 <= 0;
    //     div_4_counter <= div_4_counter + 1'b1;
    // end
    // // Div 5
    // if(rst) begin
    //     div_5 <= 0;
    //     div_5_counter <= 0;
    // end else if(div_5_counter >= div_5_period) begin
    //     div_5 <= 1'b1;
    //     div_5_counter <= 0;
    // end else if(div_5_counter < div_5_duty) begin
    //     div_5 <= 1'b1;
    //     div_5_counter <= div_5_counter + 1'b1;
    // end else begin
    //     div_5 <= 0;
    //     div_5_counter <= div_5_counter + 1'b1;
    // end
    // // Div 8
    // if(rst) begin
    //     div_8 <= 0;
    //     div_8_counter <= 0;
    // end else if(div_8_counter >= div_8_period) begin
    //     div_8 <= 1'b1;
    //     div_8_counter <= 0;
    // end else if(div_8_counter < div_8_duty) begin
    //     div_8 <= 1'b1;
    //     div_8_counter <= div_8_counter + 1'b1;
    // end else begin
    //     div_8 <= 0;
    //     div_8_counter <= div_8_counter + 1'b1;
    // end
    // // Div 16
    // if(rst) begin
    //     div_16 <= 0;
    //     div_16_counter <= 0;
    // end else if(div_16_counter >= div_16_period) begin
    //     div_16 <= 1'b1;
    //     div_16_counter <= 0;
    // end else if(div_16_counter < div_16_duty) begin
    //     div_16 <= 1'b1;
    //     div_16_counter <= div_16_counter + 1'b1;
    // end else begin
    //     div_16 <= 0;
    //     div_16_counter <= div_16_counter + 1'b1;
    // end
end

endmodule
