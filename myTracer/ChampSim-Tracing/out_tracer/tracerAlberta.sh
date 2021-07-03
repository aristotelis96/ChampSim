#!/bin/bash



if [ "$#" -ne 5 ]; then
	echo "Usage /path/to/executable /path/to/input/control {control file line to read} outputFileName /traingingLength(in billions)"
	exit 2
fi


PIN_DIR="/home/users/avontz/ChampSim-Tracing/pin-3.11-97998-g7ecce2dac-gcc-linux"
TRACER_DIR="/home/users/avontz/ChampSim-Tracing/tracer/obj-intel64"
OUT_DIR="/home/users/avontz/ChampSim-Tracing/out_tracer"

EXECUTABLE=$1
INPUT_DIR=$2
INPUT_NAME=$3

INPUT=`cat ${INPUT_DIR}/input/control | grep "${INPUT_NAME}" | tail -1`
#XZ="cld.tar.xz"
#INPUT=${INPUT/cld.tar/$XZ}
OUT_BBV=$4 # output name file
RECORDING_PERIOD=$5
# ${PIN_DIR}/pin -t ${TRACER_DIR}/basic_block_vectors_tracer.so -p <period> -o <name of bbv file> -- EXECUTABLE

# -p is the recording period for the basic blocks. I used billion
# -o is just the output file where the basic blocks will be

#test me
cd `dirname $EXECUTABLE`

${PIN_DIR}/pin -t ${TRACER_DIR}/basic_block_vectors_tracer.so -p ${RECORDING_PERIOD}000000000 -o ${OUT_DIR}/bbv/${OUT_BBV} -- ${EXECUTABLE} ${INPUT_DIR}/input/${INPUT}  &> ${OUT_DIR}/out
