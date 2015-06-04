add_package --build generic http://ftp.gnu.org/gnu/bison/bison-3.0.4.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/bison

pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
