
PROG:
	djtgcfg prog -i 0 -d Nexys3 -f $(PROJNAME)-synthdir/layoutdefault/design.bit

%.prog:
	$(NICE) $(MAKE) -f Makefile PROG PROJNAME="$*"
