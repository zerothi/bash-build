for p in OLD/ParMetis-3.2.0.tar.gz ; do
add_package http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/$p

# Correct the old version of parmetis...
pack_set --alias parmetis
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set $(list --prefix "--host-reject " thul surt slid etse a0 b0 c0 d0 n0 p0 q0 g0)

pack_set --install-query $(pack_get --install-prefix)/lib/libparmetis.a

pack_set --module-requirement openmpi

# Make commands 
pack_set --command "echo '# The start of a new Makefile.in' > Makefile.in"
pack_set --command "sed -i '1 a\
CC = $MPICC \n\
OPTFLAGS = $CFLAGS \n\
LD = $MPICC \n\
AR = $AR rv \n\
RANLIB = ranlib \n\
VERNUM = $(pack_get --version)\n\
LIBDIR = \n\
INCDIR = \n\
COPTIONS = -DNDEBUG\n' Makefile.in"

pack_set --command "make"
# Do the manual installation...
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include"
pack_set --command "cp libmetis.a $(pack_get --install-prefix)/lib"
pack_set --command "cp libparmetis.a $(pack_get --install-prefix)/lib"
pack_set --command "cp parmetis.h $(pack_get --install-prefix)/include"
pack_set --command "cp METISLib/metis.h $(pack_get --install-prefix)/include"
pack_set --command "sed -i -e 's|.../parmetis.h.|<parmetis.h>|' $(pack_get --install-prefix)/include/metis.h"

done



