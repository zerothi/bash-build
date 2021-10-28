v=3.1.5
add_package https://github.com/cmbi/hssp/releases/download/$v/hssp-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libhssp.a
pack_set -lib -lhssp

pack_set -mod-req zeep

pack_cmd "../configure" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > hssp.test 2>&1"
pack_cmd "make install"
pack_store hssp.test
