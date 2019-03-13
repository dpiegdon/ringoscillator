
DEVICE=hx1k
PACKAGE=tq144
PCF=icestick.pcf

#QUIET=-q

TESTBENCHES=$(wildcard *_tb.v)
TESTS=$(TESTBENCHES:%.v=%.test)

.PHONY: all prog run_tests clean

.PRECIOUS: %.json %.asc %.bin %.rpt




all: top.rpt

prog: top.bin
	iceprog $<

run_tests: $(TESTS)
	make -C buildingblocks run_tests
	@for test in $^; do \
		echo $$test; \
		./$$test; \
	done




clean:
	-rm -f *.json
	-rm -f *.asc
	-rm -f *.bin
	-rm -f *.rpt
	-rm *_tb.test




top.json: \
	buildingblocks/ringoscillator.v \
	buildingblocks/lfsr.v \
	buildingblocks/random.v \
	buildingblocks/synchronous_reset_timer.v \
	buildingblocks/uart.v \
	top.v




%_tb.test: %_tb.v %.v
	iverilog -o $@ $^

%.json: %.v
	yosys -Q $(QUIET) -p 'synth_ice40 -top $(subst .v,,$<) -json $@' $^

%.asc: %.json
	@# "--force" is required because nextpnr sees the combinatorial
	@# loop of a ringoscillator and raises an error
	nextpnr-ice40 $(QUIET) --force --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -p $(PCF) -P $(PACKAGE) -d $(DEVICE) -r $@ -m -t $<


