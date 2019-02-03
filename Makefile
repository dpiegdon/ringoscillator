
.PHONY: all prog clean

all: ringosc.bin ringosc.rpt

prog: ringosc.bin
	iceprog ringosc.bin

clean:
	rm -fv ringosc.bin ringosc.asc ringosc.blif ringosc.json

ringosc.blif: ringosc.v
	yosys -p 'synth_ice40 -blif ringosc.blif' ringosc.v

ringosc.json: ringosc.v
	yosys -p 'synth_ice40 -json ringosc.json' ringosc.v

#ringosc.asc: ringosc.blif icestick.pcf
#	arachne-pnr -d 1k -P tq144 -o ringosc.asc -p icestick.pcf $<

ringosc.asc: ringosc.json icestick.pcf
	# "--force" is required because nextpnr sees the combinatorial loop and raises an error
	nextpnr-ice40 --force --hx1k --package tq144 --pcf icestick.pcf --json $< --asc $@

ringosc.rpt: ringosc.asc
	icetime -d hx1k -mtr ringosc.rpt ringosc.asc


ringosc.bin: ringosc.asc
	icepack ringosc.asc ringosc.bin

