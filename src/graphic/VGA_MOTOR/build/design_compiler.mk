
$(PROJNAME)-synthdir/dc/synth/synth.tcl: build/dc_synthesize.tcl
	@echo
	@echo '*** Copying synthesis script ***'
	@echo
	mkdir -p $(@D)
	cp build/dc_synthesize.tcl $(@D)/synth.tcl

$(PROJNAME)-synthdir/dc/synth/designinfo.tcl: $(S)
	@echo
	@echo '*** Generate design info script ***'
	@echo
	mkdir -p $(@D)
	rm -f $(@D)/designtmp
	echo 'set TOPLEVEL '$$(basename $$(echo $(firstword $(S)) | sed 's/\..*$$//')) >> $@.tmp
	$(foreach i,$(filter %.v,$(S)), echo 'read_verilog "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.sv,$(S)), echo 'read_sverilog "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.vhd,$(S)), echo 'read_vhdl "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.vhdl,$(S)), echo 'read_vhdl "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.v,$(S)), echo 'analyze -format verilog "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.sv,$(S)), echo 'analyze -format sverilog "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.vhd,$(S)), echo 'analyze -format vhdl "$(call fixpath3,$(i))"' >> $@.tmp;)
	$(foreach i,$(filter %.vhdl,$(S)), echo 'analyze -format vhdl "$(call fixpath3,$(i))"' >> $@.tmp;)
	mv $@.tmp $@

$(PROJNAME)-synthdir/dc/synth/design.v: $(PROJNAME)-synthdir/dc/synth/synth.tcl $(PROJNAME)-synthdir/dc/synth/designinfo.tcl $(S)
	cd $(PROJNAME)-synthdir/dc/synth; dc_shell -f synth.tcl

%.synth: 
	$(NICE) $(MAKE) -f $(firstword $(MAKEFILE_LIST)) $*-synthdir/dc/synth/design.v  PROJNAME="$*"
