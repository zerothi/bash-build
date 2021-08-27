v=8.8.1
add_package -directory tinker \
	    https://dasher.wustl.edu/tinker/downloads/tinker-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/sniffer

pack_set -mod-req fftw

# Install commands that it should run
pack_cmd "mkdir -p $(pack_get -prefix)/bin"
pack_cmd "cd source"
pack_cmd "cp ../make/Makefile ."

# append stuff
pack_cmd "sed -i '$ a\
TINKERDIR = $(pack_get -prefix)\n\
LINKDIR = $(pack_get -prefix)/bin\n\
FFTWDIR = $(pack_get -prefix fftw)\n\
F77 = $FC \n\
F77FLAGS = -c $FCFLAGS $FLAG_OMP\n\
OPTFLAGS = $FCFLAGS $FLAG_OMP\n\
RENAME = rename_bin\n\
RANLIB = $RANLIB -c\n\
LINKFLAGS = \$(OPTFLAGS)\n' Makefile"

pack_cmd "make all $(get_make_parallel)"
pack_cmd "make install"
