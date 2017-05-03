# Make sure we can include this from more than one place without any
# issues:
ifneq ($(UTILISINCLUDED),1)


# The default shell for make is /bin/sh which doesn't work for some of
# the commands used in these files.
SHELL=/bin/bash


# Make sure we are running at low priority...
NICE = nice -n 19

# Reverses the order of all arguments given to the function.
reverse_order = $(if $(1), $(word $(words $(1)),$(1)) $(call reverse_order,$(wordlist 2,$(words $(1)),dummy $(1))),$(1))

# Fix the path by inserting ../../.. if the path is relative. If absolute, do nothing
fixpath3 = $(shell echo "$(1)" | sed 's,^\([^/]\),../../../\1,')

# Fix the path by inserting ../.. if the path is relative. If absolute, do nothing
fixpath2 = $(shell echo "$(1)" | sed 's,^\([^/]\),../../\1,')


# Fix the path by inserting ../ if the path is relative. If absolute, do nothing
fixpath1 = $(shell echo "$(1)" | sed 's,^\([^/]\),../\1,')

export S
export INCDIRS
export T
export U
export PART
export PROJNAME


sanitycheckclock:
	$(foreach i,$(S), bash sanitycheck.sh "$(i)" &&) true

sanitychecksynth: sanitycheckclock
	@if [ "$(S)" == "" ]; then echo 'ERROR: No synthesizable files specified!';false;fi

sanitychecktb: sanitycheckclock
	@if [ "$(T)" == "" ]; then echo 'ERROR: No testbench files specified!';false;fi
	@if [ "$(S)" == "" ]; then echo 'WARNING: No synthesizable files specified!';fi



%.clean:
	rm -rf "$*-synthdir" "$*-simdir"



clean:
	rm -rf *synthdir *simdir *~



UTILISINCLUDED=1
endif

