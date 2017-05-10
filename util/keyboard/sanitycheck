#!/bin/bash

if sed 's/--.*//' < "$1" | grep -n \'event
then
    echo "ERROR in $1: Du använder nyckelordet 'event. Om du vill kolla efter en klockflank bör rising_edge användas istället. Om du vill använda 'event till något annat i syntetiserbar kod bör du antagligen tänka om."
    exit 1
fi

if sed 's/--.*//' < "$1" | egrep -n 'rising_edge *\(.*\)' | egrep -v 'rising_edge *\( *clk *\)'
then
    echo "ERROR in $1: Du försöker klocka på något som antagligen inte är en riktigt klocka. Du bör enbart använda rising_edge(clk) i din syntetiserbara kod."
    exit 1
fi

if sed 's/--.*//' < "$1" | egrep -n 'falling_edge'
then
    echo "ERROR in $1: Du använder nyckelordet falling_edge i filen $1. I den här kursen bör du inte behöva använda det nyckelordet."
    exit 1
fi


