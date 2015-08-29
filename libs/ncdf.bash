v=0.27
add_package \
    --archive ncdf-$v.tar.gz \
    https://github.com/zerothi/ncdf/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libncdf.a

pack_set --module-requirement fdict
pack_set --module-requirement netcdf

# Create the arch-make file
file=arch.make
pack_cmd "echo '# Hello' > $file"
pack_cmd "sed -i '1 a\
FC = $MPIFC\n\
FC_SERIAL = $FC\n\
FFLAGS = $FCFLAGS\n\
PP = cpp -E -P -C \n\
LIBVARDICT = $(pack_get --LD fdict)/libvardict.a \n\
INC = $(list --INCDIRS $(pack_get --mod-req-path))\n\
LIB_PATH = $(list --LD-rp $(pack_get --mod-req-path))\n\
LIBS = \$(LIB_PATH) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
FPPFLAGS = -DNCDF_PARALLEL -DNCDF_4\n\
AR = $AR\n\
.F90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$(FPPFLAGS) \$< \n\
.f90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$< \n\
' $file"

# Make commands
pack_cmd "export DIR_FDICT=$(pack_get --prefix fdict)/include"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1"
pack_cmd "unset DIR_FDICT"
pack_set_mv_test tmp.test
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp src/libncdf.a $(pack_get --LD)/"
pack_cmd "cp src/*.mod $(pack_get --prefix)/include/"

