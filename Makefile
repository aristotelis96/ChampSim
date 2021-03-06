app = champsim

srcExt = cc
srcDir = src branch replacement prefetcher
objDir = obj
binDir = bin
inc = inc

debug = 1

CFlags = -Wall -O3 -std=gnu++14
LDFlags = -static-libstdc++ -D_GLIBCXX_USE_CXX11_ABI=0 
libs = 
libDir =

install_root=/local/avontz/libtorch
#-std=gnu++14 
pytorchFlags=-I${install_root}/include -I${install_root}/include/torch/csrc/api/include -L${install_root}/lib -Wl,-R${install_root}/lib -ltorch -ltorch_cpu -lc10

boost_root=/local/avontz/boost_1_62_0/
boostFlags=-I${boost_root} -lz -lboost_iostreams
#************************ DO NOT EDIT BELOW THIS LINE! ************************

ifeq ($(debug),1)
	debug=-g
else
	debug=
endif
inc := $(addprefix -I,$(inc))
libs := $(addprefix -l,$(libs))
libDir := $(addprefix -L,$(libDir))
CFlags += -c $(debug) $(inc) $(libDir) $(libs)
sources := $(shell find $(srcDir) -name '*.$(srcExt)')
srcDirs := $(shell find . -name '*.$(srcExt)' -exec dirname {} \; | uniq)
objects := $(patsubst %.$(srcExt),$(objDir)/%.o,$(sources))

ifeq ($(srcExt),cc)
	CC = $(CXX)
else
	CFlags += -std=gnu99
endif

.phony: all clean distclean


all: $(binDir)/$(app)

$(binDir)/$(app): buildrepo $(objects)
	@mkdir -p `dirname $@`
	@echo "Linking $@..."
	@$(CC) $(objects) $(LDFlags) $(boostFlags)  -o $@

$(objDir)/%.o: %.$(srcExt)
	@echo "Generating dependencies for $<..."
	@$(call make-depend,$<,$@,$(subst .o,.d,$@))
	@echo "Compiling $<..."
	@$(CC) $(CFlags) $< -o $@

clean:
	$(RM) -r $(objDir)

distclean: clean
	$(RM) -r $(binDir)/$(app)

buildrepo:
	@$(call make-repo)

define make-repo
   for dir in $(srcDirs); \
   do \
	mkdir -p $(objDir)/$$dir; \
   done
endef


# usage: $(call make-depend,source-file,object-file,depend-file)
define make-depend
  $(CC) -MM       \
        -MF $3    \
        -MP       \
        -MT $2    \
        $(CFlags) \
        $1
endef
