#!/bin/bash
source env.sh
ps aux | grep w_run | grep -v grep
pkill -9 -f w_run

SFX=.d$$
mv seg_logs{,$SFX}
mv istates{,$SFX}
rm -Rf traj_segs$SFX seg_logs$SFX istates$SFX & disown %1
rm -f system.h5 west.h5 seg_logs.tar
mkdir seg_logs istates traj_segs

BSTATE_ARGS="--bstate init_coords_a,0.8,init_coords_a.npy --bstate init_coords_b,0.2,init_coords_b.npy"

$WEST_ROOT/bin/w_init $BSTATE_ARGS --segs-per-state 10 --work-manager=threads "$@"
