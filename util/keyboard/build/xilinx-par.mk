# FIXME - rule to create ngd file from edf file as well...

dump_backendsettings:
	@echo
	@echo "   *** Important settings for the Xilinx Backend module ***"
	@echo
	@echo "   Synthesis top module: $$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//'))"
	@echo "   FPGA part (PART): $(PART)"
	@echo "   Constraints file: $(U)"
	@echo


# This is the default rule for NGDBuild when we are not trying to override our TIMESPEC
$(PROJNAME)-synthdir/layoutdefault/%.ngd: $(PROJNAME)-synthdir/synth/design.ngc $(U) 
	@echo
	@echo '*** Producing NGD file ***'
	@echo
	rm -rf $(@D)/_ngo
	mkdir -p $(@D)/_ngo
# Running ngdbuild without any UCF file
	if [ "$(U)" == "" ]; then \
		cd $(@D); $(XILINX_INIT) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) ../synth/design.ngc  design.ngd;\
	else \
		cd $(@D); $(XILINX_INIT) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) -uc $(call fixpath2,$(U)) ../synth/design.ngc  design.ngd;\
	fi


# This is the default rule for NGDBuild when we are not trying to override our TIMESPEC
$(PROJNAME)-synthdir/layoutdefault/%.ngd: $(PROJNAME)-synthdir/synth/design.edf $(U)
	@echo
	@echo '*** Producing NGD file ***'
	@echo
	rm -rf $(@D)/_ngo
	mkdir -p $(@D)/_ngo
# Running ngdbuild without any UCF file
	if [ "$(U)" == "" ]; then \
		cd $(@D); $(XILINX_INIT) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) ../synth/design.edf  design.ngd;\
	else \
		cd $(@D); $(XILINX_INIT) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) -uc $(call fixpath2,$(U)) ../synth/design.edf  design.ngd;\
	fi


# This is the rule for NGDBuild when we are trying to override the TIMESPEC when using a project.fmax rule
$(PROJNAME)-synthdir/layout%/design.ngd: $(PROJNAME)-synthdir/synth/design.ngc $(U)
	@echo
	@echo '*** Producing NGD file ***'
	@echo
	rm -rf $(@D)/_ngo
	mkdir -p $(@D)/_ngo
	@if [ "$(U)" == "" ]; then \
            echo 'Cannot synthesize to a specific MHz without a UCF file'; false; \
        fi

# At this point we try to override the default time constraint!
	@if ! [ $$(grep -i TIMESPEC $(U) | wc -l) -eq 1 ]; then echo The script can only handle one timespec for now.;false;fi
	@if ! egrep -q '^TIMESPEC ".*" *= *PERIOD *".*" *[0-9\.]+ *ns *HIGH *50 *% *;' $(U);then\
            echo 'TIMESPEC line in UCF must be in the following format: TIMESPEC "name" = PERIOD 4.5 ns HIGH 50%;';\
	    false;\
        fi
	sed 's/^\(TIMESPEC *".*" *= *PERIOD *".*"\) *[0-9\.]\+ *ns *HIGH  *50 *%; *$$/\1 $* HIGH 50%;/' < $(U) > $(@D)/design.ucf
	@echo "*** UCF file setup for timespec $* ***"
	cd $(@D); $(XILINX_INIT) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) -uc design.ucf  ../synth/design.ngc  design.ngd



# Map a design into the FPGA components
$(PROJNAME)-synthdir/layout%/design_map.ncd $(PROJNAME)-synthdir/layout%/design.pcf: $(PROJNAME)-synthdir/layout%/design.ngd
	@echo
	@echo '*** Mapping design ***'
	@echo
	cd $(@D);$(XILINX_INIT) map -detail -u -p  $(PART) -pr b -c 100 -o design_map.ncd design.ngd design.pcf

# Rule for placing and routing a design
$(PROJNAME)-synthdir/layout%/design.ncd: $(PROJNAME)-synthdir/layout%/design_map.ncd $(PROJNAME)-synthdir/layout%/design.pcf
	@echo
	@echo '*** Routing design ***'
	@echo
	cd $(@D); $(XILINX_INIT) par -nopad -w  -ol high design_map.ncd design.ncd design.pcf 

$(PROJNAME)-synthdir/layoutdefault/design_postpar.vhd: $(PROJNAME)-synthdir/layoutdefault/design.ncd
	@echo
	@echo '*** Creating post place and route netlist $* ***'
	@echo
	$(XILINX_INIT) netgen -w -ofmt vhdl $(@D)/design.ncd $@



$(PROJNAME)-synthdir/layout%/design.twr: $(PROJNAME)-synthdir/layout%/design.ncd
	@echo
	@echo '*** Running static timing analysis ***'
	@echo
	cd $(@D); $(XILINX_INIT) trce -v 1000 design.ncd design.pcf

$(PROJNAME)-synthdir/layoutdefault/design.xdl: work $(PROJNAME)-synthdir/layoutdefault/design.ncd
	@echo
	@echo '*** Creating XDL netlist ***'
	@echo
	cd $(@D); $(XILINX_INIT) xdl -w -ncd2xdl design.ncd


$(PROJNAME)-synthdir/layoutdefault/design.bit: $(PROJNAME)-synthdir/layoutdefault/design.ncd
	cd $(@D); $(XILINX_INIT) bitgen -w design.ncd


# Duplicate the layout dependencies a couple of time with different
# timespecs to enable parallel make to investigate several different
# timing specs simultaneously on multi processor machines.
#
# Warning: You may have a limited amount of licenses for ISE!
expandtimespec = $(shell echo 'scale=5;for(i=0;i<25;i+=1){$(1)-i*0.1;print " "}'|bc)
$(PROJNAME)-synthdir/fmax.rpt: $(foreach i,$(call expandtimespec,$(TIMESPEC)),$(PROJNAME)-synthdir/layout$(i)/design.twr)
	@echo 
	@echo '*** Maximum frequencies follow ***'
	@echo 
	grep MHz $(PROJNAME)-synthdir/layout*/design.twr


# The rules below are the only rules that are expected to actually be
# called by a normal user of this makefile.

%.bitgen: dump_backendsettings
	$(NICE) $(MAKE) -f Makefile $*-synthdir/layoutdefault/design.bit PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" INCDIRS="$(INCDIRS)"

%.fmax: dump_backendsettings
	$(NICE) $(MAKE) -f Makefile $*-synthdir/fmax.rpt  PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" TIMESPEC=$(TIMESPEC) INCDIRS="$(INCDIRS)"



%.route: dump_backendsettings
	$(NICE) $(MAKE) -f Makefile $*-synthdir/layoutdefault/design.ncd  PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" INCDIRS="$(INCDIRS)"

%.timing: dump_backendsettings
	$(NICE) $(MAKE) -f Makefile $*-synthdir/layoutdefault/design.twr PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" INCDIRS="$(INCDIRS)"

%.xdl: dump_backendsettings
	$(NICE) $(MAKE) -f Makefile $*-synthdir/layoutdefault/design.xdl PROJNAME="$*" S="$(S)" U="$(U)" XST_OPT="$(XST_OPT)" PART="$(PART)" T="$(T)" INCDIRS="$(INCDIRS)"

