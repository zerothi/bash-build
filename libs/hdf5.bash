# Then install HDF5
for p in 1.8.14 ; do

add_package http://www.hdfgroup.org/ftp/HDF5/releases/hdf5-$p/src/hdf5-$p.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhdf5.a

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
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--with-zlib=$(pack_get --prefix zlib)" \
    --command-flag --enable-parallel \
    --command-flag --enable-shared \
    --command-flag --enable-static \
    --command-flag "--enable-fortran" $tmp

# Make commands
pack_set --command "make $(get_make_parallel)"
if ! $(is_host n- hemera eris ponto surt muspel slid) ; then
  pack_set --command "make check-s > tmp.test 2>&1"
  pack_set_mv_test tmp.test tmp.test.s
fi
# the parallel tests cannot even complete using gnu
#pack_set --command "NPROCS=3 make check-p > tmp.test 2>&1"
#pack_set_mv_test tmp.test tmp.test.p
pack_set --command "make install"

done
