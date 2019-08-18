
#ARCH=ecp5
#DEVICE=um5g-85k
#PACKAGE=CABGA381
#PINCONSTRAINTS=ecp5-evn.lpf
#BITSTREAM=top_ecp5.svf
#TIMINGREPORT=

#ARCH=ice40
#DEVICE=lp384
#PACKAGE=qn32
#PINCONSTRAINTS=lp384.pcf
#BITSTREAM=top_ice40.bin
#TIMINGREPORT=top_ice40.rpt

ARCH=ice40
DEVICE=hx1k
PACKAGE=tq144
PINCONSTRAINTS=icestick.pcf
BITSTREAM=top_ice40.bin
TIMINGREPORT=top_ice40.rpt

#QUIET=-q

TESTBENCHES=$(wildcard *_tb.v)
TESTS=$(TESTBENCHES:%.v=%.test)

.PHONY: all prog run_tests clean randomness_test

.PRECIOUS: %.json %.asc %.bin %.rpt %.txtcfg


all: $(BITSTREAM) $(TIMINGREPORT)

prog: $(BITSTREAM)
ifeq ($(ARCH),ice40)
	iceprog $<
else ifeq ($(ARCH),ecp5)
	openocd -f ecp5-evn.openocd.conf -c "transport select jtag; init; svf progress quiet $<; exit"
else
	false
endif


run_tests: $(TESTS)
	make -C verilog-buildingblocks run_tests
	@for test in $^; do \
		echo $$test; \
		./$$test; \
	done


randomness_test:
	# requires tools from NIST Entropy Assessment,
	# see https://github.com/usnistgov/SP800-90B_EntropyAssessment
	socat file:/dev/ttyUSB1,b3000000,cs8,rawer,ignoreeof STDOUT | dd bs=128 count=8192 iflag=fullblock > random.raw
	ea_non_iid -i -a -v random.raw 8
	ea_iid -i -a -v random.raw 8
	ea_non_iid -c -a -v random.raw 8
	ea_iid -c -a -v random.raw 8


clean:
	-rm -f *.json
	-rm -f *.asc
	-rm -f *.bin
	-rm -f *.rpt
	-rm -f *.txtcfg
	-rm -f *.svf
	-rm *_tb.test
	-rm random.raw


top_$(ARCH).json: \
	verilog-buildingblocks/lfsr.v \
	verilog-buildingblocks/binary_debias.v \
	verilog-buildingblocks/lattice_$(ARCH)/ringoscillator.v \
	verilog-buildingblocks/lattice_$(ARCH)/random.v \
	verilog-buildingblocks/random.v \
	verilog-buildingblocks/synchronous_reset_timer.v \
	verilog-buildingblocks/uart.v \
	top.v


%_tb.test: %_tb.v %.v
	iverilog -o $@ $^


%_ice40.json: %.v
	yosys -Q $(QUIET) -p 'synth_ice40 -top $(subst .v,,$<) -json $@' $^

%_ice40.asc: %_ice40.json
	nextpnr-$(ARCH) $(QUIET) --ignore-loops --$(DEVICE) --package $(PACKAGE) --pcf $(PINCONSTRAINTS) --json $< --asc $@

%_ice40.bin: %_ice40.asc
	icepack $< $@

%_ice40.rpt: %_ice40.asc
	icetime -p $(PINCONSTRAINTS) -P $(PACKAGE) -d $(DEVICE) -r $@ -m -t $<


%_ecp5.json: %.v
	yosys -Q $(QUIET) -p 'synth_ecp5 -top $(subst .v,,$<) -json $@' $^

%_ecp5.txtcfg: %_ecp5.json
	nextpnr-ecp5 $(QUIET) --ignore-loops --$(DEVICE) --package $(PACKAGE) --lpf $(PINCONSTRAINTS) --json $< --textcfg $@

%_ecp5.svf: %_ecp5.txtcfg
	ecppack --svf $@ $<

