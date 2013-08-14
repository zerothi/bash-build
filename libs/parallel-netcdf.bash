# This package requires that flex and bison is installed

# Install the Parallel NetCDF
add_package \
    --package pnetcdf \
    http://ftp.mcs.anl.gov/pub/parallel-netcdf/parallel-netcdf-1.3.1.tar.bz2

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libpnetcdf.a

pack_set --module-requirement openmpi
if [ $(pack_get --installed bison) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement bison) $(pack_get --module-name bison)"
fi
if [ $(pack_get --installed flex) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-mpi=$(pack_get --install-prefix openmpi)" \
    --command-flag "--enable-fortran"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

if [ $(pack_get --installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
if [ $(pack_get --installed bison) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name bison) $(pack_get --module-name-requirement bison)"
fi
