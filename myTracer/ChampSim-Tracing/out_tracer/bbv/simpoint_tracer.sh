if [ "$#" -ne 5 ]; then
	echo "Usage: ./simpoint_tracer /path/to/benchmark/executable /path/to/input /path/to/output/filename TracingPoint(in Billions) Interval(in Billions)"
	exit 2
fi


PIN_DIR="/local/avontz/ChampSim-Tracing/pin-3.11-97998-g7ecce2dac-gcc-linux"
TRACER_DIR="/local/avontz/ChampSim-Tracing/tracer/obj-intel64"

EXECUTABLE=$1
INPUT=$2

OUTDIR=$(dirname $3)
OUTPUT=$3

TRACING_POINT="$4" # start
INTERVAL="$5" #how many instructions to trace

cd ${EXECUTABLE_DIR}

${PIN_DIR}/pin -t ${TRACER_DIR}/champsim_tracer.so -o ${OUTPUT}-${TRACING_POINT}B.champsimtrace -s ${TRACING_POINT}000000000 -t ${INTERVAL}000 -- ${EXECUTABLE} ${INPUT} &> ${OUTDIR}/out
cd ${OUTDIR}
xz ${OUTPUT}-${TRACING_POINT}B.champsimtrace
