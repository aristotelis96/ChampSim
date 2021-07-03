SIMPOINT_PATH=/home/users/avontz/ChampSim-Tracing/out_tracer
SIMPOINT_FLAGS=-maxK 10

# Getting the list of simpoints files that we have to generate.
BBV_FILES := $(wildcard *.bb)
SIMPOINTS_FILES := $(addprefix output/, $(BBV_FILES:%.bb=%.simpoints))
WEIGHTS_FILES := $(addprefix output/, $(BBV_FILES:%.bb=%.weights))

all: dirs $(SIMPOINTS_FILES) $(WEIGHTS_FILES)

# Creates the required directories.
dirs:
	mkdir -p output

# Getting the basic blocks from the cluster.
#get_bbv_gapbs:
#	scp $(MN_USERNAME)@$(MN_HOST):$(MN_PATH)/bbv.tar.gz ./
#	tar -xzf bbv.tar.gz
#	rm bbv.tar.gz

output/%.simpoints: %.bb
	$(SIMPOINT_PATH)/simpoint $(SIMPOINT_FLAGS) -loadFVFile $< -saveSimpoints $@

output/%.weights: %.bb
	$(SIMPOINT_PATH)/simpoint $(SIMPOINT_FLAGS) -loadFVFile $< -saveSimpointWeights $@

# Cleaning rules for this project.
.PHONY: clean

clean:
	rm -r output

mrproper: clean
	rm ./*.bb

