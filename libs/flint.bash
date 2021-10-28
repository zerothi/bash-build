add_package http://flintlib.org/flint-2.8.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE 

pack_set -install-query $(pack_get -LD)/libflint.a
pack_set -lib -lflint

pack_cmd "./configure --prefix=$(pack_get -prefix)"
pack_cmd "make"
pack_cmd "make check > flint.test 2>&1"
pack_store flint.test
pack_cmd "make install"
