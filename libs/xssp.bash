v=3.0.10
add_package https://github.com/cmbi/xssp/releases/download/$v/xssp-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libxssp.a
pack_set -lib -lxssp

pack_set -mod-req zeep

pack_cmd "../configure" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > xssp.test 2>&1"
pack_cmd "make install"
pack_store xssp.test
