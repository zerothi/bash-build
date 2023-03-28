v=1.8
add_package https://ftp.gnu.org/gnu/pies/pies-$v.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -install-query $(pack_get -prefix)/bin/piesctl

pack_set -build-mod-req build-tools

pack_cmd "../configure --prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > pies.check 2>&1"
pack_cmd "make install"
pack_store pies.check
