for v in 3.0.12 4.1.1
do
add_package -build generic http://prdownloads.sourceforge.net/swig/swig-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -module-requirement pcre
pack_set -module-requirement gen-boost

pack_set -install-query $(pack_get -prefix)/bin/swig

pack_cmd "./configure" \
	 "--prefix $(pack_get -prefix)" \
	 "--with-pcre-prefix=$(pack_get -prefix pcre)" \
	 "--with-boost=$(pack_get -prefix gen-boost)" \
	 "--without-lua" \
	 "--without-java --without-android" \
	 "--without-guile --without-ocaml" \
	 "--without-ruby" \
	 "--without-php --without-pike" \
	 "--without-mzscheme --without-chicken" \
	 "--without-go --without-d"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

done
