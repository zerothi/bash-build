add_package http://valgrind.org/downloads/valgrind-3.10.1.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/valgrind

if $(is_c intel) ; then
    # valgrind currently only installs using GCC
    pack_set --host-reject $(get_hostname)
fi

pack_set --module-opt "--lua-family valgrind"
pack_set --module-requirement mpi

pack_set --command "../configure --with-mpicc=$MPICC" \
    --command-flag "--enable-only64bit" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
