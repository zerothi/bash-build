v=2.23.0
add_package -archive arb-$v.tar.gz https://github.com/fredrik-johansson/arb/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libarb.so
pack_set -lib -larb

pack_set -mod-req flint

opts=
if $(is_c gnu) ; then
  _prefix=$(pack_get -prefix $(get_c -name)[$(get_c -version)])
  opts="--with-gmp=$_prefix --with-mpfr=$_prefix)"
else
  pack_set -mod-req gmp -mod-req mpfr
  opts="--with-gmp=$(pack_get -prefix gmp) --with-mpfr=$(pack_get -prefix mpfr)"
fi

pack_cmd "./configure --with-flint=$(pack_get -prefix flint) $opts" \
	 "--prefix=$(pack_get -prefix)"
pack_cmd "make"
pack_cmd "make check > arb.test 2>&1"
pack_store arb.test
pack_cmd "make install"

