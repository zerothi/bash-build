add_package http://flintlib.org/flint-2.9.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE 

pack_set -install-query $(pack_get -LD)/libflint.a
pack_set -lib -lflint

opts=
if $(is_c gnu) ; then
  _prefix=$(pack_get -prefix gcc[$(get_c -version)])
  opts="--with-gmp=$_prefix --with-mpfr=$_prefix"
else
  pack_set -mod-req gmp -mod-req mpfr
  opts="--with-gmp=$(pack_get -prefix gmp) --with-mpfr=$(pack_get -prefix mpfr)"
fi

pack_cmd "./configure --prefix=$(pack_get -prefix) $opts"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > flint.test 2>&1 || echo 'forced'"
pack_store flint.test
pack_cmd "make install"
