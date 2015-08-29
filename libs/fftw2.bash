add_package --alias fftw-2 \
    http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libfftw.a

pack_cmd "../configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"

pack_set_mv_test tmp.test


add_package --alias fftw-mpi-2 --package fftw-mpi \
    http://www.fftw.org/fftw-2.1.5.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --mod-req mpi

pack_set --install-query $(pack_get --LD)/libfftw_mpi.a

pack_cmd "../configure --enable-mpi" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"

pack_set_mv_test tmp.test

