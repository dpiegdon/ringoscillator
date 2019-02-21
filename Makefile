
DEVICE=hx1k
PACKAGE=tq144
PCF=icestick.pcf




.PHONY: all prog clean

.PRECIOUS: %.json %.asc %.bin %.rpt




all: top.rpt

prog: top.bin
	iceprog $<

clean:
	-rm -f *.json
	-rm -f *.asc
	-rm -f *.bin
	-rm -f *.rpt




top.json: \
	buildingblocks/randomized_lfsr16.v \
	buildingblocks/lfsr.v \
	buildingblocks/metastable_oscillator.v \
	buildingblocks/ringoscillator.v \
	buildingblocks/synchronous_reset_timer.v \
	buildingblocks/uart.v \
	top.v




%.json: %.v
	yosys -Q -q -p 'synth_ice40 -top $(subst .v,,$<) -json $@' $^

%.asc: %.json
	@# "--force" is required because nextpnr sees the combinatorial
	@# loop of a ringoscillator and raises an error
	nextpnr-ice40 -q --force --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -p $(PCF) -P $(PACKAGE) -d $(DEVICE) -r $@ -m -t $<

