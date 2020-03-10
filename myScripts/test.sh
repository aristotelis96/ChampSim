#!/bin/bash

cd /home/users/avontz/ChampSim

for BIN in `ls ./bin/scalingExec/PB`; do
	./bin/scalingExec/PB/${BIN} -warmup_instructions 1 -simulation_instructions 100000 -traces /local/vkarakos/hpca23-traces/600.perlbench_s-210B.champsimtrace.xz
done;
