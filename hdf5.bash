# Then install HDF5
add_package http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.9.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL \
    -s $IS_MODULE -s $LOAD_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query \
    $(pack_get --install-prefix)/lib/libhdf5.a

# Add requirments when creating the module
pack_set --module-requirement openmpi \
    --module-requirement zlib

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF90} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)" \
    --command-flag --enable-parallel \
    --command-flag --disable-shared \
    --command-flag --enable-static \
    --command-flag --enable-fortran \
    --command-flag --enable-fortran2003
		#--enable-shared  # They are not tested with parallel

# Make commands
pack_set --command "make $(get_make_parallel)"
# make check fails due to a bug in the test suite....
pack_set --command "make" \
    --command-flag "install"
