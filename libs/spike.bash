add_package http://www.ecs.umass.edu/~polizzi/spike/spike-1.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libspike.a
pack_set --lib -lspike

# Install commands that it should run
pack_cmd "cd src"

# Make commands
pack_cmd "echo '# make' > make.inc"
pack_cmd "sed -i '$ a\
ARCH =.\n\
INSTALLDIR = $(pack_get --prefix)\n\
OPTION = 1\n\
CC = $CC \n\
CFLAGS = -c $CFLAGS\n\
F90 = $FC \n\
F90FLAGS = -c $FCFLAGS $FLAG_OMP\n' make.inc"
pack_cmd "make INSTALLDIR=$(pack_get --prefix) all"
