# This package requires that flex and bison is installed

# Install the Parallel NetCDF
add_package \
    --package pnetcdf \
    http://cucis.ece.northwestern.edu/projects/PnetCDF/Release/parallel-netcdf-1.5.0.tar.bz2

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libpnetcdf.a

pack_set --module-requirement openmpi
if [ $(pack_installed bison) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement bison) $(pack_get --module-name bison)"
fi
if [ $(pack_installed flex) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--with-mpi=$(pack_get --prefix openmpi)" \
    --command-flag "--enable-fortran"

# Make commands
pack_set --command "make $(get_make_parallel)"
if ! $(is_host hemera eris ponto) ; then
	pack_set --command "make check > tmp.test 2>&1"
fi
pack_set --command "make install"
if ! $(is_host hemera eris ponto) ; then
	pack_set_mv_test tmp.test
fi


if [ $(pack_installed flex) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi
if [ $(pack_installed bison) -eq 1 ] ; then
    pack_set --command "module unload $(pack_get --module-name bison) $(pack_get --module-name-requirement bison)"
fi
