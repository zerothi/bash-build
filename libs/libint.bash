v=2.6.0
add_package -archive libint-$v.tar.gz https://github.com/evaleev/libint/archive/v$v.tar.gz

pack_set -lib -lint2 -lstdc++

pack_set -s $IS_MODULE -s $BUILD_DIR
pack_set -build-mod-req build-tools
pack_set -mod-req boost

pack_set -install-query $(pack_get -LD)/libint.a

pack_cmd "pushd .. ; ./autogen.sh ; popd"
pack_cmd "../configure --enable-eri=1 --enable-eri2=1 --enable-eri3=1 --with-max-am=5" \
	 "--with-boost=$(pack_get -prefix boost)" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libint.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store libint.test

