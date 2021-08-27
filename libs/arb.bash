v=2.18.1
add_package -archive arb-$v.tar.gz https://github.com/fredrik-johansson/arb/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libarb.so
pack_set -lib -larb

pack_set -mod-req flint

pack_cmd "./configure --with-flint=$(pack_get -prefix flint)" \
	 "--prefix=$(pack_get -prefix)"
pack_cmd "make"
pack_cmd "make check > arb.test 2>&1"
pack_store arb.test
pack_cmd "make install"

