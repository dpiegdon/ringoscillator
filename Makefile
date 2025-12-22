
#ARCH=ecp5
#DEVICE=um5g-85k
#PACKAGE=CABGA381
#PINCONSTRAINTS=ecp5-evn.lpf
#OUTPUTEXTENSION=svf
#REPORTEXTENSION=svf

#ARCH=ice40
#DEVICE=lp384
#SYNTH_ICE40_DEV=lp
#PACKAGE=qn32
#PINCONSTRAINTS=lp384.pcf
#OUTPUTEXTENSION=bin
#REPORTEXTENSION=rpt

ARCH=ice40
DEVICE=hx1k
SYNTH_ICE40_DEV=hx
PACKAGE=tq144
PINCONSTRAINTS=icestick.pcf
OUTPUTEXTENSION=bin
REPORTEXTENSION=rpt

#QUIET=-q

UARTDEV=/dev/serial/by-id/usb-Lattice_Lattice_FTUSB_Interface_Cable-if01-port0

# RNG seed for nextpnr-ice40. Try different values if you have not fully utilized the FPGAs logic but get placement issues.
# Otherwise keep fixed to get a deterministic behavior.
# You can also use `-r` to try random values. The used seed is listed in the first line of nextpnr's output.
#SEED=--seed=123456789
SEED=-r

# the size-constrained LP384 seems to work better with `sa' placing algorithm. some designs don't work with the standard placer `heap', or at least not very well.
#PLACER=--placer sa

# enable to ignore synthesis loops
IGNORE_LOOPS=--ignore-loops

TESTBENCHES=$(wildcard *_tb.v)
TESTS=$(TESTBENCHES:%.v=%.test)

.PHONY: all prog run_tests graphs clean randomness_test source_randomness

.PRECIOUS: %.json %.asc %.bin %.rpt %.txtcfg

TOPLEVEL_FILES = $(wildcard *.v)

# generic targets:
all: $(subst .v,.$(OUTPUTEXTENSION),$(TOPLEVEL_FILES)) $(subst .v,.$(REPORTEXTENSION),$(TOPLEVEL_FILES))

prog: top.$(OUTPUTEXTENSION)
ifeq ($(ARCH),ice40)
	iceprog $<
endif
ifeq ($(ARCH),ecp5)
	openocd -f ecp5-evn.openocd.conf -c "transport select jtag; init; svf progress quiet $<; exit"
endif


run_tests: $(TESTS)
	make -C verilog-buildingblocks run_tests
	@for test in $^; do \
		echo $$test; \
		./$$test; \
	done

clean:
	-rm -f *.json
	-rm -f *.asc
	-rm -f *.bin
	-rm -f *.rpt
	-rm -f *.dot
	-rm -f *.png
	-rm -f *.txtcfg
	-rm -f *.svf
	-rm *_tb.test
	-rm *_tb.vcd
	-rm random.raw

graphs: $(subst .v,.png,$(TOPLEVEL_FILES))

randomness_test:
	# receive random data from device and do NIST SP800-90B entropy assessment tests.
	# usefull for entropy-generator configuration.
	# requires tools from NIST Entropy Assessment, see https://github.com/usnistgov/SP800-90B_EntropyAssessment
	socat -u file:$(UARTDEV),b3000000,ignoreeof,cs8,raw,echo=0 STDOUT | dd bs=1000 count=1000 > random.raw
	ea_non_iid -i -a -v random.raw 8
	ea_iid -i -a -v random.raw 8
	ea_non_iid -c -a -v random.raw 8
	ea_iid -c -a -v random.raw 8

source_randomness:
	# usefull for entropy-generator configuration.
	# receive random data from device and pipe it into the kernel entropy pool.
	socat -u file:$(UARTDEV),b3000000,ignoreeof,cs8,raw,echo=0 STDOUT | sudo tee /dev/random | pv > /dev/null



# generic pattern rules
%.dot: %.v
	yosys -p '$(^:%.v=read_verilog %.v;) proc; opt_clean -purge; opt -fine -full -share_all; show -colors 1 -width -stretch -format dot -prefix $(subst .dot,,$(notdir $@))'
	# demux multiple graphs from one file:
	gvpr 'BEG_G { fname = sprintf("$(subst .dot,,$(notdir $@))__%s.dot",$$G.name); writeG($$G, fname); }' $(notdir $@)

%.png: %.dot
	# actually create PNGs for all the demuxed modules, not the parent file
	for F in $(subst .dot,,$(notdir $<))__*.dot  ; do $$F; dot -Tpng $$F > $$F.png; done;
	# and delete the parent file
	-rm $(notdir $<)

%_tb.test: %_tb.v
	verilator -DTESTBENCH --top-module $(patsubst %_tb.test,%,$@) +1800-2012ext+v --lint-only -Wall -Wno-PROCASSINIT --bbox-unsup $(patsubst %_tb.test,%.v,$@)
	iverilog  -DTESTBENCH -g2012 -Wall -Wno-timescale -o $@ $^

%.json: %.v
	@# also see:
	@# - https://yosyshq.readthedocs.io/projects/yosys/en/latest/using_yosys/more_scripting/interactive_investigation.html
	@# - https://github.com/Ravenslofty/yosys-cookbook/blob/master/ice40.md
	@# - https://github.com/Ravenslofty/yosys-cookbook/blob/master/ecp5.md
ifeq ($(ARCH),ice40)
	yosys -Q $(QUIET) -DARCH_$(ARCH)=1 -p 'proc; opt_clean -purge; opt -fine -full -share_all; synth_$(ARCH) -device ${SYNTH_ICE40_DEV} -dff -abc2 -top $(subst .v,,$<) -json $@' $^
endif
ifeq ($(ARCH),ecp5)
	yosys -Q $(QUIET) -DARCH_$(ARCH)=1 -p 'proc; opt_clean -purge; opt -fine -full -share_all; synth_$(ARCH) -abc9 -top $(subst .v,,$<) -json $@' $^
endif

# ICE40:
%.asc: %.json
	@# https://github.com/YosysHQ/nextpnr/blob/master/docs/generic.md
	@# https://github.com/YosysHQ/icestorm
	@# https://prjicestorm.readthedocs.io/en/latest/
	nextpnr-$(ARCH) $(QUIET) $(SEED) $(PLACER) $(IGNORE_LOOPS) --promote-logic --opt-timing --$(DEVICE) --package $(PACKAGE) --pcf $(PINCONSTRAINTS) --json $< --asc $@

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -p $(PINCONSTRAINTS) -P $(PACKAGE) -d $(DEVICE) -r $@ -m -t $<

# ECP5:
%.txtcfg: %.json
	nextpnr-$(ARCH) $(QUIET) $(SEED) $(PLACER) $(IGNORE_LOOPS) --$(DEVICE) --package $(PACKAGE) --lpf $(PINCONSTRAINTS) --json $< --textcfg $@ --report $(subst .json,.rpt,$<)

%.svf: %.txtcfg
	ecppack --svf $@ $<
