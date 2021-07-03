export PIN_ROOT=/home/users/avontz/ChampSim-Tracing/pin-3.11-97998-g7ecce2dac-gcc-linux
#export PIN_ROOT=/home/bscuser/Tools/ChampSim-Tracing/pin-3.10-97971-gc5e41af74-gcc-linux
#export PIN_ROOT=/home/bscuser/Tools/ChampSim-Tracing/pin-3.6-97554-g31f0a167d-gcc-linux
mkdir -p obj-intel64
#make obj-intel64/champsim_tracer.so # this is for the actual champsim_tracer
make obj-intel64/basic_block_vectors_tracer.so # this is for the simpoint tracer
