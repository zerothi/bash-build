v=0.19
add_package \
    --archive ncdf-$v.tar.gz \
    https://github.com/zerothi/ncdf/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/lib/libncdf.a

pack_set --module-requirement fvar
pack_set --module-requirement netcdf

# Create the arch-make file
file=arch.make
pack_set --command "echo '# Hello' > $file"
pack_set --command "sed -i '1 a\
FC = $MPIFC\n\
FC_SERIAL = $FC\n\
FFLAGS = $FCFLAGS\n\
PP = cpp -E -P -C \n\
LIBVARDICT = $(pack_get --LD fvar)/libvardict.a \n\
INC = $(list --INCDIRS $(pack_get --mod-req-path))\n\
LIB_PATH = $(list --LDFLAGS --Wlrpath $(pack_get --mod-req-path))\n\
LDFLAGS = \$(LIB_PATH) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
FPPFLAGS = -DNCDF_PARALLEL -DNCDF_4\n\
AR = $AR\n\
.F90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$(FPPFLAGS) \$< \n\
.f90.o:\n\
\t\$(FC) -c \$(INC) \$(FFLAGS) \$< \n\
' $file"

# Make commands
pack_set --command "export DIR_FVAR=$(pack_get --prefix fvar)/include"
pack_set --command "make $(get_make_parallel)"
pack_set --command "make test > tmp.test 2>&1"
pack_set --command "unset DIR_FVAR"
pack_set_mv_test tmp.test
pack_set --command "mkdir -p $(pack_get --LD)"
pack_set --command "mkdir -p $(pack_get --prefix)/include"
pack_set --command "cp src/libncdf.a $(pack_get --LD)/"
pack_set --command "cp src/*.mod $(pack_get --prefix)/include/"

