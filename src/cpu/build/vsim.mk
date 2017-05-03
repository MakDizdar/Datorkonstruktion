# Needed for modelsim compilation of VHDL files
T_REV=$(call reverse_order,$(T))
S_REV=$(call reverse_order,$(S))

#Enable this to set coverage...
#COVERAGE=-cover bcst
#FIXME - INCDIR handling

VERILOGCOMPILE=vlog +acc $(COVERAGE) $(INCDIR)
VHDLCOMPILE=vcom +acc $(COVERAGE)
BATCHSIM?=vsim -c -do 'run -a;quit -f'
GUISIM?=vsim

# TODO: Don't recompile all files all the time!
# (Re)compile all files used for the testbench

$(PROJNAME)-simdir/work:
	mkdir -p $(PROJNAME)-simdir
	cd $(PROJNAME)-simdir;vlib work

SIMTBFILES: $(PROJNAME)-simdir/work $(T_REV)
	$(if $(filter %.vhd,$(T_REV)),  cd $(PROJNAME)-simdir; $(VHDLCOMPILE)	 $(foreach i, $(filter %.vhd, $(T_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.vhdl,$(T_REV)), cd $(PROJNAME)-simdir; $(VHDLCOMPILE)	 $(foreach i, $(filter %.vhdl, $(T_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.v,$(T_REV)),    cd $(PROJNAME)-simdir; $(VERILOGCOMPILE) $(foreach i, $(filter %.v, $(T_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.sv,$(T_REV)),   cd $(PROJNAME)-simdir; $(VERILOGCOMPILE) $(foreach i, $(filter %.sv, $(T_REV)), $(call fixpath1,$(i))))

SIMSYNTHFILES: $(PROJNAME)-simdir/work $(S_REV)			
	$(if $(filter %.vhd,$(S_REV)),  cd $(PROJNAME)-simdir; $(VHDLCOMPILE)	 $(foreach i, $(filter %.vhd, $(S_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.vhdl,$(S_REV)), cd $(PROJNAME)-simdir; $(VHDLCOMPILE)	 $(foreach i, $(filter %.vhdl, $(S_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.v,$(S_REV)),    cd $(PROJNAME)-simdir; $(VERILOGCOMPILE) $(foreach i, $(filter %.v, $(S_REV)), $(call fixpath1,$(i))))
	$(if $(filter %.sv,$(S_REV)),   cd $(PROJNAME)-simdir; $(VERILOGCOMPILE) $(foreach i, $(filter %.sv, $(S_REV)), $(call fixpath1,$(i))))


SIMFILES: SIMSYNTHFILES SIMTBFILES sanitychecktb sanitycheck

# FIXME - How to handle for example  -L unisim ?
SIM: SIMFILES
	cd $(PROJNAME)-simdir;$(GUISIM) $$(basename $$(echo $(firstword $(T)) | sed 's/\..*$$//'))

SIMC: SIMFILES
	cd $(PROJNAME)-simdir; $(BATCHSIM) $$(basename $$(echo $(firstword $(T)) | sed 's/\..*$$//'))


#	vcom  +acc $(PROJNAME)-synthdir/xst/synth//design_postsynth.vhd
SYNTHSIMC: $(POSTSYNTHSIMNETLIST) SIMTBFILES
	echo $*
	$(NICE) $(MAKE) -f Makefile SIMC S="$(POSTSYNTHSIMNETLIST)" PROJNAME=$(PROJNAME) BATCHSIM="$(BATCHSIM) $(MODELSIM_POSTSYNTH_OPTIONS)"



%.simfiles:
	$(NICE) $(MAKE) -f Makefile SIMFILES PROJNAME="$*"

%.sim:
	$(NICE) $(MAKE) -f Makefile SIM PROJNAME="$*"

%.simc:
	$(NICE) $(MAKE) -f Makefile SIMC PROJNAME="$*"

%.synthsimc:
	$(NICE) $(MAKE) -f Makefile SYNTHSIMC PROJNAME="$*" 
