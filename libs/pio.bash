v=2.5.1
add_package https://github.com/NCAR/ParallelIO/releases/download/pio_${v//./_}/pio-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libpio.so
pack_set -lib -lpio

pack_set -mod-req netcdf

pack_cmd "CC=$MPICC FC=$MPIFC ../configure --enable-fortran --prefix $(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
# pio tests require around 8 processors to succeed
#pack_cmd "make check > pio.check 2>&1"
pack_cmd "make install"
#pack_store pio.check
