v=0.3.2
add_package \
    --archive ncdf-$v.tar.gz \
    https://github.com/zerothi/ncdf/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libncdf.a

pack_set --module-requirement fdict
pack_set --module-requirement netcdf

# Create the arch-make file
file=setup.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '1 a\
FC = $MPIFC\n\
FFLAGS = $FFLAGS\n\
CPP = cpp -E -P -C \n\
FDICT_PREFIX = $(pack_get --prefix fdict)\n\
INCLUDES = $(list --INCDIRS $(pack_get --mod-req-path))\n\
LIB_PATH = $(list --LD-rp $(pack_get --mod-req-path))\n\
LIBS = \$(LIB_PATH) -lfdict -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
FPPFLAGS = -DNCDF_PARALLEL -DNCDF_4\n\
AR = $AR\n\
' $file"

# Make commands
pack_cmd "cp $(pack_get --prefix fdict)/bin/settings.bash ."
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install PREFIX=$(pack_get --prefix)"
pack_cmd "make test > tmp.test 2>&1 || echo 'Fail'"
pack_set_mv_test tmp.test

