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

#Number of CPU for parallel execution
CPU_NUM=4
open_sem $CPU_NUM

cd /home/users/avontz/ChampSim/

TRACE_DIR=/local/vkarakos/hpca23-traces

N_WARM=50000000
N_SIM=2000000000
OPTION="-hide_heartbeat -show_IPs"

ACCURACY=99
OCCURRENCES=15000
MISSPREDICTIONS=1000
RESET_WINDOW=30000000

OUTPUT_FOLDER=correctedWindowReset

task(){
	TRACE=$1    
	echo "Now running trace:" $TRACE "For accuracy:" $ACCURACY;	
	(./bin/TAGE8_windowReset -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} ${OPTION} -accuracy=${ACCURACY} -occurrences=${OCCURRENCES} -misspredictions=${MISSPREDICTIONS} -reset_window=${RESET_WINDOW} -traces ${TRACE_DIR}/${TRACE}) &>  ./results/H2P/${OUTPUT_FOLDER}/${TRACE}.txt 
}


mkdir -p ./results/H2P/${OUTPUT_FOLDER}
for TRACE in `cat ./myScripts/H2PTraces.txt`; do
    run_with_lock task $TRACE
done;
