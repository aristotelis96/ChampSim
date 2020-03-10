#!/bin/bash

TRACE_DIR=/local/vkarakos/hpca23-traces
BINARY=traceInstrCounter
W_SIM=0
N_SIM=10000000000
OPTION=-hide_heartbeat

CPU_NUM=4

cd /home/users/avontz/ChampSim

mkdir -p results_InstrSum
for TRACE in `ls $TRACE_DIR`; do
	((i=i%CPU_NUM)); ((i++==0)) && wait
	(./bin/${BINARY} -warmup_instructions ${W_SIM} -simulation_instructions ${N_SIM} ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &> results_InstrSum/${TRACE}.txt &
done;
exit;
