# Makefile to build UPduino v3.0 top.v with icestorm toolchain
# Original Makefile is taken from: 
# https://github.com/tomverbeure/upduino/tree/master/blink
# On Linux, copy the included upduinov3.rules to /etc/udev/rules.d/ so that we don't have
# to use sudo to flash the bit file.

top.bin: top.asc
	icepack build/top.asc build/top.bin

top.asc: top.json hw/upduino.pcf
	nextpnr-ice40 --randomize-seed --up5k --package sg48 --json build/top.json --pcf hw/upduino.pcf --asc build/top.asc   # run place and route

top.json: src/top.v
	mkdir -p build
	yosys -p "synth_ice40 -json build/top.json" src/top.v

.PHONY: flash
flash:
	iceprog -d i:0x0403:0x6014 rgb_blink.bin

.PHONY: clean
clean:
	$(RM) -f build/top.json build/top.asc build/top.bin 
	rmdir build
