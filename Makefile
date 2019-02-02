
ringosc.bin: ringosc.txt
	icepack ringosc.txt ringosc.bin

ringosc.txt: ringosc.blif icestick.pcf
	arachne-pnr -d 1k -o ringosc.txt -p icestick.pcf ringosc.blif

ringosc.blif: ringosc.v
	yosys -p 'synth_ice40 -blif ringosc.blif' ringosc.v

prog: ringosc.bin
	iceprog ringosc.bin

clean:
	rm -fv ringosc.bin ringosc.txt ringosc.blif

