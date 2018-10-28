add_package ftp://sourceware.org/pub/valgrind/valgrind-3.14.0.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/valgrind

if $(is_c intel) ; then
    # valgrind currently only installs using GCC
    pack_set --host-reject $(get_hostname)
fi

pack_set --module-opt "--lua-family valgrind"
pack_set --module-requirement mpi

pack_cmd "../configure --with-mpicc=$MPICC" \
    "--enable-only64bit" \
    "--prefix=$(pack_get --prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
