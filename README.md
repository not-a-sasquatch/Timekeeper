# Clockwork lemon

A clock generator eurorack module based on the Upduino open source FPGA development board (FPGA: Lattic UltraPlus ICE40UP5K)

## TO DO
change mul_2, mul_3, mul_4, etc. counter lengths
Make 10 bit ADC input compatible with clk_divider

## Build instruction

Yosys: open source synthesis tool for Verilog code
Nextpnr: open source place & route tool
IceStorm: open source bitsream generation tool targeting iCE40 FPGAs

Build & programming instructions
    make
    iceprog top.bin

## Simulation instructions

SPI module testbench:
    verilator -cc tb/spi_module_tb.v
    verilator -Wall --trace -cc tb/spi_module_tb.v --exe tb/tb_spi.cpp
    make -C obj_dir -f Vspi_module_tb.mk Vspi_module_tb
    ./obj_dir/Vspi_module_tb
    gtkwave waveform.vcd

SPI controller testbench:
    verilator -cc tb/spi_controller_tb.v
    verilator -Wall --trace -cc tb/spi_controller_tb.v --exe tb/tb_spi_controller.cpp
    make -C obj_dir -f Vspi_controller_tb.mk Vspi_controller_tb
    ./obj_dir/Vspi_controller_tb
    gtkwave waveform.vcd

Clock divider testbench:
    verilator -cc tb/clk_div_tb.v
    verilator -Wall --trace -cc tb/clk_div_tb.v --exe tb/tb_div.cpp
    make -C obj_dir -f Vclk_div_tb.mk Vclk_div_tb
    ./obj_dir/Vclk_div_tb
    gtkwave waveform.vcd

## Documentation

UPduino documentation:
https://upduino.readthedocs.io/en/latest/index.html

UPduino v3 github:
https://github.com/tinyvision-ai-inc/UPduino-v3.0

Yosys github:
https://github.com/YosysHQ/yosys

NextPNR github:

https://github.com/YosysHQ/nextpnr

Verilator documentation:
https://verilator.org/guide/latest/overview.html

GTKWave page:
https://gtkwave.sourceforge.net/

UPduino page:
https://tinyvision.ai/products/fpga-development-board-upduino-v3-1