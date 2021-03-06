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

OUTPUT_FOLDER=/local/avontz/myTraces/datasets/541.leela
H2P_LOG_DIR=/home/users/avontz/ChampSim/results/H2P/myTraces/H2Ps/541.leela
TRACE_DIR=/local/avontz/myTraces/541.leela
STATISTICS_LOG_DIR=/home/users/avontz/ChampSim/results/H2P/myTraces/H2P_AccuracyPerBranch/TAGE8/541.leela
N_WARM=50000000
N_SIM=1000000000
OPTION='-hide_heartbeat -collect_H2P_dataset -dataset_random'
#OPTION='-hide_heartbeat -collect_H2P_dataset'

#Number of CPU for parallel execution
CPU_NUM=4
open_sem $CPU_NUM

cd /home/users/avontz/ChampSim/

mkdir -p ${OUTPUT_FOLDER}


task(){	
	TRACE=$1
	echo "Now running for trace:" $TRACE;	
	mkfifo ${OUTPUT_FOLDER}/${TRACE}.Pipe
	
	(./bin/collect_dataset -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -perfect_H2P_file=${H2P_LOG_DIR}/${TRACE}.txt -dataset_random_file=${STATISTICS_LOG_DIR}/${TRACE}.txt ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &>  ${OUTPUT_FOLDER}/${TRACE}.Pipe &
	gzip < ${OUTPUT_FOLDER}/${TRACE}.Pipe -c > ${OUTPUT_FOLDER}/${TRACE}._.dataset_random.txt.gz
	rm ${OUTPUT_FOLDER}/${TRACE}.Pipe
}


for TRACE in `ls ${TRACE_DIR}`; do		
    	run_with_lock task $TRACE			
        #(./bin/collect_dataset -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -perfect_H2P_file=${H2P_LOG_DIR}/${TRACE}.txt ${OPTION} -traces ${TRACE_DIR}/${TRACE}) &>  ./results/Dataset/${TRACE}._.dataset_unique.txt 
done;

