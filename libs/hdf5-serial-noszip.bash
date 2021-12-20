for p in $(pack_get -version hdf5) ; do

add_package \
    --package hdf5-serial-noszip \
    https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-$p/src/hdf5-$p.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libhdf5.a
pack_set --lib[fortran] -lhdf5_fortran -lhdf5
pack_set --lib[hl] -lhdf5_hl -lhdf5
pack_set --lib[fortranhl] -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5

# Add requirments when creating the module
pack_set --module-requirement zlib

tmp="--enable-fortran2003"
if $(is_c gnu-4.1) ; then
    unset tmp
fi

# Install commands that it should run
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--with-zlib=$(pack_get --prefix zlib)" \
	 "--enable-shared" \
	 "--enable-static" \
	 "--enable-fortran" $tmp

# Make commands
pack_cmd "make $(get_make_parallel)"
if ! $(is_host n- surt muspel slid) ; then
    pack_cmd "make check > hdf5.test 2>&1 || echo forced"
    pack_store hdf5.test
fi
pack_cmd "make install"

done
