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

BENCH=505.mcf
#alberta/ref
TRACE_TYPE=ref

OUTPUT_FOLDER=/home/users/avontz/ChampSim/results/H2P/myTraces/H2P_AccuracyPerBranch/TAGE8/${BENCH}
H2P_LOG_DIR=/home/users/avontz/ChampSim/results/H2P/myTraces/H2Ps/${BENCH}
TRACE_DIR=/local/avontz/myTraces/${BENCH}/${TRACE_TYPE}
N_WARM=50000000
N_SIM=1000000000
OPTION='-hide_heartbeat -measure_H2P_accuracy'
#OPTION='-measure_H2P_accuracy'
#CNNpt='-pytorch_pt=/home/users/avontz/ChampSim/bin/CNN.pt'
CNNpt=''

EXECUTABLE=measure_H2P_accuracy

#Number of CPU for parallel execution
CPU_NUM=40
open_sem $CPU_NUM

cd /home/users/avontz/ChampSim/

task(){	
	TRACE=$1
	echo "Now running for trace:" $TRACE;	
	(./bin/${EXECUTABLE} -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -perfect_H2P_file=${H2P_LOG_DIR}/${TRACE}.txt ${CNNpt} ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &>  ${OUTPUT_FOLDER}/${TRACE}.txt
}

mkdir -p ${OUTPUT_FOLDER}
#for TRACE in `cat ./myScripts/H2PTraces.txt | grep "600"`; do		
for TRACE in `ls ${TRACE_DIR}`; do
    	run_with_lock task $TRACE			
        #(./bin/collect_dataset -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -perfect_H2P_file=${H2P_LOG_DIR}/${TRACE}.txt ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &>  ./results/Dataset/${TRACE}._.dataset_unique.txt 
done;
wait
