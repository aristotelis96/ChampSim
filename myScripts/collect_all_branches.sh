#!/bin/bash
#PBS -e err
#PBS -o out
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

#ex: 500.perlbench
if [ -z "$BENCH" ]; then
    BENCH=531.deepsjeng
fi;
#ex: alberta/ref
if [ -z "$TRACE_TYPE" ]; then
    TRACE_TYPE=alberta
fi;

OUTPUT_FOLDER=/local/avontz/myTraces/datasets/${BENCH}/allBranches
TRACE_DIR=/local/avontz/myTraces/${BENCH}/${TRACE_TYPE}
N_WARM=50000000
N_SIM=1000000000
OPTION='-hide_heartbeat -collect_all_branches'

#Number of CPU for parallel execution
if [ -z "$CPU_NUM" ]; then
    CPU_NUM=20
fi;

open_sem $CPU_NUM

cd /home/users/avontz/ChampSim/

mkdir -p ${OUTPUT_FOLDER}


task(){	
	TRACE=$1
	echo "Now running for trace:" $TRACE;	
	./bin/collect_all_branches -warmup_instructions ${N_WARM} -simulation_instructions ${N_SIM} -collect_all_branches_file ${OUTPUT_FOLDER}/${TRACE}._.allBranches.txt.gz ${OPTION}  -traces ${TRACE_DIR}/${TRACE}
}


for TRACE in `ls ${TRACE_DIR}`; do		
    	run_with_lock task $TRACE			
done;
wait
