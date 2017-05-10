sh date

# set some per design variables FIXME - use these!
# set LOG_PATH  "synth/dc_test_synth/log/"
# set GATE_PATH "synth/dc_test_synth/gate/"
# set RTL_PATH  "synth/dc_test_synth/verilog/"

# Should be moved to a synthesis setup dot file?
set target_library {/sw/mentor/libraries/cmos065_522/CORE65LPLVT_5.1/libs/CORE65LPLVT_nom_1.20V_25C.db}
set link_library $target_library 



proc dir_exists {name} {
    if { [catch {set type [file type $name] } ]  } {
	return 0;
    } 
    if { $type == "directory" } {
	return 1;
    }
    return 0;

}

source designinfo.tcl


if {[dir_exists $TOPLEVEL.out]} {
    sh rm -r ./$TOPLEVEL.out
}
sh mkdir ./$TOPLEVEL.out

set power_preserve_rtl_hier_names true


current_design $TOPLEVEL

elaborate $TOPLEVEL

# Set timing constaints, this says that a max of .5ns of delay from
# input to output is allowable 
#set_max_delay .1 -from [all_inputs] -to [all_outputs]


# If this were a clocked piece of logic we could set a clock
#  period to shoot for like this 
set_clock_gating_style  -max_fanout 16

# Some default settings, you probably need to change this for your
# particular project!
create_clock clk -period 2
set_input_delay -clock clk 0.1 [all_inputs]
set_output_delay -clock clk 0.1 [all_outputs]



# FIXME - check this!
#optimize_registers -sync_trans multiclass 

# Check for warnings/errors 
check_design

# ungroup everything 
ungroup -flatten -all

# flatten it all, this forces all the hierarchy to be flattened out 
set_flatten true -effort high
uniquify

# This forces the compiler to spend as much effort (and time)
# compiling this RTL to achieve timing possible. 
#
# Clock gating is enabled by default to reduce power.
compile_ultra -gate_clock

# Now that the compile is complete report on the results 

check_design > ./$TOPLEVEL.out/check_design.rpt

report_constraint -all_violators -verbose  > constraint.rpt
report_wire_load > wire_load_model_used.rpt
report_area > area.rpt
report_qor > qor.rpt
report_timing -max_paths 1000 > timing.rpt


report_ultra_optimization > ultraopt.rpt
report_power -verbose > power_estimate.rpt
report_design > ./$TOPLEVEL.out/design_information.rpt
report_resources > ./$TOPLEVEL.out/resources.rpt

# Finally write the post synthesis netlist out to a verilog file 
write -f verilog -output synthesized_netlist.v -hierarchy

quit
