v=0.4.0
add_package \
    --archive ncdf-$v.tar.gz \
    https://github.com/zerothi/ncdf/releases/download/v$v/ncdf-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/lib/libncdf.a

pack_set --module-requirement fdict
pack_set --module-requirement netcdf

# Create the arch-make file
file=setup.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '$ a\
FC = $MPIFC\n\
FFLAGS = $FFLAGS\n\
FDICT_PREFIX = $(pack_get --prefix fdict)\n\
INCLUDES = $(list --INCDIRS $(pack_get --mod-req-path)) -I../src\n\
LIB_PATH = $(list --LD-rp $(pack_get --mod-req-path))\n\
LIBS = \$(LIB_PATH) -lfdict -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
FPPFLAGS = -DNCDF_PARALLEL -DNCDF_4\n\
AR = $AR\n\
RANLIB = $RANLIB\n\
' $file"

pack_cmd "echo 'CDF=4' > Makefile"
pack_cmd "echo 'MPI=1' >> Makefile"
pack_cmd "echo 'TOP_DIR=..' >> Makefile"
pack_cmd "echo 'include ../Makefile' >> Makefile"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install PREFIX=$(pack_get --prefix)"
pack_cmd "make test > tmp.test 2>&1 || echo 'Fail'"
pack_set_mv_test tmp.test
