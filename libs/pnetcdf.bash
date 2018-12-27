# This package requires that flex and bison is installed

# Install the Parallel NetCDF
v=1.11.0
add_package \
    --package pnetcdf \
    https://parallel-netcdf.github.io/Release/pnetcdf-$v.tar.gz

pack_set -s $BUILD_DIR -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libpnetcdf.a
pack_set --lib -lpnetcdf

pack_set --module-requirement mpi
if [[ $(pack_installed bison) -eq 1 ]]; then
    pack_cmd "module load $(list ++bison)"
fi
if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(list ++flex)"
fi

# Install commands that it should run
pack_cmd "../configure" \
	 "CC=${MPICC} CXX=${MPICXX}" \
	 "F77=${MPIF77} F90=${MPIF90} FC=${MPIF90}" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-mpi=$(pack_get --prefix mpi)" \
	 "--enable-fortran --disable-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1 || echo 'Forced...'"
pack_cmd "make install"
pack_set_mv_test tmp.test

if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module unload $(list ++flex)"
fi
if [[ $(pack_installed bison) -eq 1 ]]; then
    pack_cmd "module unload $(list ++bison)"
fi
