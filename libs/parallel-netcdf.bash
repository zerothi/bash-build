# Install the Parallel NetCDF (requires bison)
add_package http://ftp.mcs.anl.gov/pub/parallel-netcdf/parallel-netcdf-1.3.1.tar.bz2

pack_set --alias pnetcdf

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --prefix-module $(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --install-query $(pack_get --install-prefix)/lib/libpnetcdf.a

pack_set --module-requirement openmpi

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
    --command-flag "tests" \
    --command-flag "install"


pack_install