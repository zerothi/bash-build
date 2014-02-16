# Then install HDF5
for p in 1.8.12 ; do

add_package http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$p/src/hdf5-$p.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libhdf5.a

# Add requirments when creating the module
pack_set --module-requirement openmpi \
    --module-requirement zlib

tmp="--command-flag --enable-fortran2003"
if $(is_c gnu-4.1) ; then
    unset tmp
fi

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CC=${MPICC} CXX=${MPICXX}" \
    --command-flag "F77=${MPIF90} F90=${MPIF90} FC=${MPIF90}" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)" \
    --command-flag --enable-parallel \
    --command-flag --disable-shared \
    --command-flag --enable-static \
    --command-flag --enable-fortran $tmp
		#--enable-shared  # They are not tested with parallel

# Make commands
pack_set --command "make $(get_make_parallel)"
#pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"

#pack_set --command "mv tmp.test $(pack_get --install-prefix)/"

done
