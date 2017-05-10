# Command to initialize the Xilinx environment
# (Feel free to change to the 64 bit version if necessary.)
#XILINX_INIT = source /sw/xilinx/ise_11.1i/ISE/settings32.sh;
#XILINX_INIT = source /extra/ise_11.1/ISE/settings32.sh;




# This rule is responsible for creating the XST synthesis script and
# the PRJ file containing the name of the files we want to synthesize

.PRECIOUS: $(PROJNAME)-synthdir/%.scr $(PROJNAME)-synthdir/%.prj %.ncd $(PROJNAME)-synthdir/%.ngc $(PROJNAME)-synthdir/%.ngd $(PROJNAME)-synthdir/%_map.ncd $(PROJNAME)-synthdir/%.ncd $(PROJNAME)-synthdir/%.edf  %.ncd %.bit

$(PROJNAME)-synthdir/xst/synth/design.scr: $(S)
	@echo
	@echo '*** Creating synthesis scripts ***'
	@echo
	mkdir -p $(@D)
# We first create the project file
	@rm -f $@.tmp
	@echo "set -tmpdir tmpdir" > $@.tmp
	@echo "run -ifn design.prj" >> $@.tmp
	@echo "-ofn design.ngc" >> $@.tmp
# The following lines finds the first specified synthesizable file,
# removes the file extension by using sed and then removing the
# directory part of the file by using basename. This is then used as
# our top module!
	echo "-top $$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//'))" >> $@.tmp
	echo "-p $(PART)" >> $@.tmp
	echo $(XST_OPT) >> $@.tmp
# First enter all Verilog files into the project file, then all VHDL files
	rm -f $(@D)/design.prj
	touch $(@D)/design.prj
	$(foreach i,$(filter %.v,$(S)), echo 'verilog work "$(call fixpath3,$(i))"' >> $(@D)/design.prj;)
	$(foreach i,$(filter %.vhd,$(S)), echo 'vhdl work "$(call fixpath3,$(i))"' >> $(@D)/design.prj;)
	$(foreach i,$(filter %.vhdl,$(S)), echo 'vhdl work "$(call fixpath3,$(i))"' >> $(@D)/design.prj;)
	mv $@.tmp $@

# Synthesize the design based on the synthesis script
# Clean out temporary directories to be sure no stale data is left...
$(PROJNAME)-synthdir/xst/synth/design.ngc: $(PROJNAME)-synthdir/xst/synth/design.scr 
	@echo
	@echo '*** Synthesizing ***'
	@echo
	rm -rf $(@D)/tmpdir
	mkdir -p $(@D)/tmpdir
	rm -rf $(@D)/xst
	mkdir -p $(@D)/xst
	cd $(@D); $(XILINX_INIT) xst -ifn design.scr -ofn design.syr

POSTSYNTHSIMNETLIST=$(PROJNAME)-synthdir/xst/synth/design_postsynth.vhd

$(POSTSYNTHSIMNETLIST): $(PROJNAME)-synthdir/xst/synth/design.ngc
	@echo
	@echo '*** Creating post synthesis netlist $* ***'
	@echo
	$(XILINX_INIT) netgen -w -ofmt vhdl $(@D)/design.ngc $@


MODELSIM_POSTSYNTH_OPTIONS=-L unisim



# TODO: Don't recompile all files all the time!
PARSIM: work $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd SIMTBFILES
	vcom +acc $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd
	cp $(PROJNAME)-synthdir/layoutdefault/design_postpar.sdf .
	vsim -sdfmax /uut=$(PROJNAME)-synthdir/layoutdefault/design_postpar.sdf -L simprim $$(basename $$(echo $(firstword $(T)) | sed 's/\..*$$//'))

# TODO: Don't recompile all files all the time!
PARSIMC: work $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd SIMTBFILES
	vcom +acc $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd
	vsim -sdfmax /uut=$(PROJNAME)-synthdir/layoutdefault/design_postpar.sdf -L simprim $$(basename $$(echo $(firstword $(T)) | sed 's/\..*$$//')) -c -do 'run -a; quit -f'


# TODO: Don't recompile all files all the time!
POWERSIM: work $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd SIMTBFILES
	vcom +acc $(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd
	vsim -sdfmax /uut=$(PROJNAME)-synthdir/layoutdefault/design_postpar.sdf -do 'vcd file activity.vcd;vcd add -r -internal -in -out uut/*; vcd  on;run -a;vcd off;vcd flush;quit -f' -c -L simprim $$(basename $$(echo $(firstword $(T)) | sed 's/\..*$$//'))
	$(XILINX_INIT) xpwr  -v -a -s activity.vcd   $(PROJNAME)-synthdir/layoutdefault/design.ncd 

$(PROJNAME)-synthdir/synth/design.ngc: $(PROJNAME)-synthdir/xst/synth/design.ngc
	mkdir -p $(@D)
	cp $< $@

export XST_EXTRA_OPTIONS



dump_synthsettings:
	@echo
	@echo "   *** Important settings for the Synthesis module ***"
	@echo
	@echo "   Synthesis top module: $$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//'))"
	@echo "   Files to synthesize:  $(S)"
	@echo "   Include directories: $(INCDIRS)"
	@echo "   FPGA part (PART): $(PART)"
	@echo "   Extra options to XST: $(XST_EXTRA_OPTIONS) (FIXME - not implemented yet in Makefile!)"
	@echo



%.synth:  sanitychecksynth
	$(NICE) $(MAKE) -f Makefile $*-synthdir/synth/design.ngc  PROJNAME="$*"






%.synthsim:
	$(NICE) $(MAKE) -f Makefile SYNTHSIM PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" T="$(T)" INCDIRS="$(INCDIRS)"

%.parsim:
	$(NICE) $(MAKE) -f Makefile PARSIM PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" T="$(T)" INCDIRS="$(INCDIRS)"



%.parsimc:
	$(NICE) $(MAKE) -f Makefile PARSIMC PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" T="$(T)" INCDIRS="$(INCDIRS)"

%.powersim:
	$(NICE) $(MAKE) -f Makefile POWERSIM PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" T="$(T)" INCDIRS="$(INCDIRS)"







