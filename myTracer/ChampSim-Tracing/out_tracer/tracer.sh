PIN_DIR="/local/avontz/ChampSim-Tracing/pin-3.11-97998-g7ecce2dac-gcc-linux"
TRACER_DIR="/local/avontz/ChampSim-Tracing/tracer/obj-intel64"
OUT_DIR="/local/avontz/ChampSim-Tracing/out_tracer"

EXECUTABLE=$1
INPUT=$2
OUT_BBV=$3 # output name file
RECORDING_PERIOD=$4
# ${PIN_DIR}/pin -t ${TRACER_DIR}/basic_block_vectors_tracer.so -p <period> -o <name of bbv file> -- EXECUTABLE

# -p is the recording period for the basic blocks. I used billion
# -o is just the output file where the basic blocks will be

#test me
cd `dirname $EXECUTABLE`

${PIN_DIR}/pin -t ${TRACER_DIR}/basic_block_vectors_tracer.so -p ${RECORDING_PERIOD}000000000 -o ${OUT_DIR}/bbv/${OUT_BBV} -- ${EXECUTABLE} ${INPUT}  &> ${OUT_DIR}/out
