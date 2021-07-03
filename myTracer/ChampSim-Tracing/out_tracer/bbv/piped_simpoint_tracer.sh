if [ "$#" -ne 6 ]; then
	echo "Usage: ./piped_simpoint_tracer /path/to/benchmark/executable /path/to/input {control file line to read} /path/to/output/filename TracingPoint(in Billions) Interval(in Billions)"
	exit 2
fi


PIN_DIR="/home/users/avontz/ChampSim-Tracing/pin-3.11-97998-g7ecce2dac-gcc-linux"
TRACER_DIR="/home/users/avontz/ChampSim-Tracing/tracer/obj-intel64"

EXECUTABLE=$1
INPUT_DIR=$2
INPUT_NAME=$3

INPUT=`cat ${INPUT_DIR}/input/control | grep "${INPUT_NAME}" | tail -n 1`
##XZ="cld.tar.xz"
##INPUT=${INPUT/cld.tar/$XZ}
OUTDIR=$(dirname $4)
OUTPUT=$4

TRACING_POINT="$5" # start
INTERVAL="$6" #how many instructions to trace


PIPE_NAME=${OUTPUT}-${TRACING_POINT}B.Pipe

mkfifo ${PIPE_NAME}

${PIN_DIR}/pin -t ${TRACER_DIR}/champsim_tracer.so -o ${PIPE_NAME} -s ${TRACING_POINT}000000000 -t ${INTERVAL}000000000 -- ${EXECUTABLE} ${INPUT_DIR}/input/${INPUT} &> ${OUTDIR}/out &
xz < ${PIPE_NAME} -c > ${OUTPUT}-${TRACING_POINT}B.champsimtrace.xz

rm ${PIPE_NAME}

