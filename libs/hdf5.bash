# Then install HDF5
for p in 1.10.4 ; do

add_package \
    --package hdf5 \
    https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-$p/src/hdf5-$p.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhdf5.a
pack_set --lib[fortran] -lhdf5_fortran -lhdf5
pack_set --lib[hl] -lhdf5_hl -lhdf5
pack_set --lib[fortranhl] -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5


# Add requirments when creating the module
pack_set --module-requirement mpi \
	 --module-requirement zlib \
	 --module-requirement szip

tmp=" --enable-fortran2003"
if $(is_c gnu-4.1) ; then
    unset tmp
fi

# Install commands that it should run
pack_cmd "../configure" \
	 "CC=${MPICC} CXX=${MPICXX}" \
	 "F77=${MPIF90} F90=${MPIF90} FC=${MPIF90}" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-zlib=$(pack_get --prefix zlib)" \
	 "--with-szlib=$(pack_get --prefix szip)" \
	 --enable-parallel \
	 --enable-shared \
	 --enable-static \
	 "--enable-fortran" $tmp

# Make commands
pack_cmd "make $(get_make_parallel)"
if ! $(is_host n- surt muspel slid) ; then
    pack_cmd "make check-s > hdf5.test 2>&1"
    pack_set_mv_test hdf5.test hdf5.test.s
fi
# the parallel tests cannot even complete using gnu
#pack_cmd "NPROCS=3 make check-p > hdf5.test 2>&1"
#pack_set_mv_test hdf5.test hdf5.test.p
pack_cmd "make install"

done
