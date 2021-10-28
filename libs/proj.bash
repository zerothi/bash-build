v=8.1.1
add_package https://github.com/OSGeo/PROJ/releases/download/$v/proj-$v.tar.gz
pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libproj.so
pack_set -lib -lproj

pack_set $(list -p '-mod-req ' sqlite curl)

pack_cmd "../configure --prefix $(pack_get -prefix) --with-curl"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > proj.test 2>&1"
pack_cmd "make install"
pack_store proj.test
