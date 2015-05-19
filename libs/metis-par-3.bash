for p in OLD/ParMetis-3.2.0.tar.gz ; do
add_package \
    --package parmetis \
    http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/$p

# Correct the old version of parmetis...
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libparmetis.a

if [ $(pack_installed cmake) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name cmake)"
fi

pack_set --module-requirement mpi

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
pack_set --command "mkdir -p $(pack_get --LD)"
pack_set --command "mkdir -p $(pack_get --prefix)/include"
pack_set --command "cp libmetis.a $(pack_get --LD)"
pack_set --command "cp libparmetis.a $(pack_get --LD)"
pack_set --command "cp parmetis.h $(pack_get --prefix)/include"
pack_set --command "cp METISLib/metis.h $(pack_get --prefix)/include"
pack_set --command "sed -i -e 's|.../parmetis.h.|<parmetis.h>|' $(pack_get --prefix)/include/metis.h"

if [ $(pack_installed cmake) -eq 1 ]; then
    pack_set --command "module unload $(pack_get --module-name cmake)"
fi

done



