
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




top.json: top.v randomized_lfsr16.v lfsr.v metastable_oscillator.v ringoscillator.v




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

