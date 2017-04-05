PRECISION=precision

# FIXME - different directoreis for different synthesis scripts?
# For precision:
$(PROJNAME)-synthdir/synth/precision/design.scr: $(S) | dump_synthsettings
	@echo
	@echo '*** Creating synthesis scripts for Precision ***'
	@echo
	mkdir -p $(@D)
	rm -f $(@D)/design.scr;
	echo set_results_dir . > $(@D)/design.scr
	echo -n 'add_input_file {' >> $(@D)/design.scr
	for i in $(S); do echo -n " \"$$PWD/$$i\"" >> $(@D)/design.scr; done
	echo '}' >> $(@D)/design.scr
	echo "setup_design -design "$$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//')) >> $(@D)/design.scr
	echo 'setup_design -manufacturer $(PRECISION_MANUFACTURER) -family $(PRECISION_FAMILY)  -part $(PRECISION_PART) -speed $(PRECISION_SPEEDGRADE)' >> $(@D)/design.scr
	echo '$(PRECISION_EXTRA_OPTIONS)'  >> $(@D)/design.scr
	echo 'setup_design -basename design' >> $(@D)/design.scr
	echo 'compile' >> $(@D)/design.scr
	echo 'synthesize' >> $(@D)/design.scr
	echo 'report_area > area.rpt' >> $(@D)/design.scr

$(PROJNAME)-synthdir/synth/precision/design.edf: $(PROJNAME)-synthdir/synth/precision/design.scr
	cd $(@D);$(NICE) $(PRECISION) -shell -file design.scr

$(PROJNAME)-synthdir/synth/design.edf: $(PROJNAME)-synthdir/synth/precision/design.edf
	cp $< $@

dump_synthsettings:
	@echo
	@echo "   *** Important settings for the Synthesis module ***"
	@echo
	@echo "   Synthesis top module: $$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//'))"
	@echo "   Files to synthesize:  $(S)"
	@echo "   Include directories: $(INCDIRS)"
	@echo "   FPGA part (PRECISION_PART): $(PRECISION_PART)"
	@echo "   FPGA familypart (PRECISION_FAMILY): $(PRECISION_FAMILY)"
	@echo "   FPGA manufacturer (PRECISION_MANUFACTURER): $(PRECISION_MANUFACTURER)"
	@echo "   FPGA speedgrade (PRECISION_SPEEDGRADE): $(PRECISION_SPEEDGRADE)"
	@echo "   Extra options to precision: $(PRECISION_EXTRA_OPTIONS)"
	@echo

export PRECISION_PART
export PRECISION_FAMILY
export PRECISION_MANUFACTURER
export PRECISION_SPEEDGRADE
export PRECISION_EXTRA_OPTIONS

# How to handle EDN files?
# $(PROJNAME)-synthdir/layoutdefault/design.ngd: $(PROJNAME)-synthdir/synth/design.ngc $(U)
#     $(@D)/%.ngd: $(@D)/%.edf %.ucf
#     	rm -rf $(@D)/_ngo
#     	mkdir $(@D)/_ngo
#     	cp *.edn $(@D)
#     	cd $(@D); $(XILINX_INIT) ngdbuild -dd _ngo -nt timestamp -p $(PART) -uc $(PWD)/$*.ucf $*.edf  $*.ngd


%.synth:
	$(NICE) $(MAKE) -f $(firstword $(MAKEFILE_LIST)) $*-synthdir/synth/precision/design.edf  PROJNAME="$*"
