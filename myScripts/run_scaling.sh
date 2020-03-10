#!/bin/bash

# Credit https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop
# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo pipe-$$
    exec 3<>pipe-$$
    rm pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}

# run the given command asynchronously and pop/push tokens
run_with_lock(){
    local x
    # this read waits until there is something to read
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
     ( "$@"; )
    # push the return code of the command to the semaphore
    printf '%.3d' $? >&3
    )&
}
H2P_LOG_DIR=/home/users/avontz/ChampSim/results/H2P/H2P_with_IP
TRACE_DIR=/local/vkarakos/hpca23-traces
N_WARM=50000000
N_SIM=2000000000
OPTION=-hide_heartbeat
# Choose between PB for Perfect Prediction OR TAGE for Tage predictor
MODE=Perfect_H2P
#Number of CPU for parallel execution
CPU_NUM=4
open_sem $CPU_NUM

cd /home/users/avontz/ChampSim/

mkdir -p results/scalingResults/${MODE}

task(){
	BINARY=$1
	TRACE=$2
	echo "Now running" $BINARY "for trace:" $TRACE;	
	(./bin/scalingExec/${MODE}/${BINARY} -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -perfect_H2P=${H2P_LOG_DIR}/${TRACE}.txt ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &>  ./results/scalingResults/${MODE}/${BINARY}/${TRACE}._.${BINARY}.txt 
}

for BINARY in `ls ./bin/scalingExec/${MODE}`; do
	mkdir -p ./results/scalingResults/${MODE}/${BINARY}
	for TRACE in `cat ./myScripts/H2PTraces.txt`; do		
			run_with_lock task $BINARY $TRACE			
	done;
done;

