# This package requires that flex and bison is installed

# Install the Parallel NetCDF
add_package http://ftp.mcs.anl.gov/pub/parallel-netcdf/parallel-netcdf-1.3.1.tar.bz2

pack_set --alias pnetcdf

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --install-query $(pack_get --install-prefix)/lib/libpnetcdf.a

pack_set --module-requirement openmpi
if [ $(pack_installed bison) -eq 1 ]; then
    pack_set --command "module load $(get_default_modules) $(pack_get --module-name bison)"
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

if [ $(pack_installed bison) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name bison) $(get_default_modules)"
fi
