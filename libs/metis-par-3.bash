for p in OLD/ParMetis-3.2.0.tar.gz ; do
add_package \
    --package parmetis \
    http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/$p

# Correct the old version of parmetis...
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libparmetis.a

pack_set --module-requirement mpi

# Make commands 
pack_cmd "echo '# The start of a new Makefile.in' > Makefile.in"
pack_cmd "sed -i '1 a\
CC = $MPICC \n\
OPTFLAGS = $CFLAGS \n\
LD = $MPICC \n\
AR = $AR rv \n\
RANLIB = ranlib \n\
VERNUM = $(pack_get --version)\n\
LIBDIR = \n\
INCDIR = \n\
COPTIONS = -DNDEBUG\n' Makefile.in"

pack_cmd "make"
# Do the manual installation...
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp libmetis.a $(pack_get --LD)"
pack_cmd "cp libparmetis.a $(pack_get --LD)"
pack_cmd "cp parmetis.h $(pack_get --prefix)/include"
pack_cmd "cp METISLib/metis.h $(pack_get --prefix)/include"
pack_cmd "sed -i -e 's|.../parmetis.h.|<parmetis.h>|' $(pack_get --prefix)/include/metis.h"

done



