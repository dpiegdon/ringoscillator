
#DEVICE=lp384
#PACKAGE=qn32
#PCF=lp384.pcf
DEVICE=hx1k
PACKAGE=tq144
PCF=icestick.pcf

#QUIET=-q

TESTBENCHES=$(wildcard *_tb.v)
TESTS=$(TESTBENCHES:%.v=%.test)

.PHONY: all prog run_tests clean randomness_test

.PRECIOUS: %.json %.asc %.bin %.rpt




all: top.rpt

prog: top.bin
	iceprog $<

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
	-rm *_tb.test
	-rm random.raw




top.json: \
	verilog-buildingblocks/ringoscillator.v \
	verilog-buildingblocks/lfsr.v \
	verilog-buildingblocks/random.v \
	verilog-buildingblocks/synchronous_reset_timer.v \
	verilog-buildingblocks/uart.v \
	top.v




%_tb.test: %_tb.v %.v
	iverilog -o $@ $^

%.json: %.v
	yosys -Q $(QUIET) -p 'synth_ice40 -top $(subst .v,,$<) -json $@' $^

%.asc: %.json
	nextpnr-ice40 $(QUIET) --ignore-loops --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -p $(PCF) -P $(PACKAGE) -d $(DEVICE) -r $@ -m -t $<


