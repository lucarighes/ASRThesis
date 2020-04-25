#!/bin/bash
num_sil_states=5
num_nonsil_states=3
silphonelist=`cat data/lang/phones/silence.csl`
nonsilphonelist=`cat data/lang/phones/nonsilence.csl`
utils/gen_topo.pl $num_nonsil_states $num_sil_states $nonsilphonelist $silphonelist > data/lang/topo
