v=2.7.2
add_package -directory libint-$v -package libint-prepare -archive libint-$v.tar.gz https://github.com/evaleev/libint/archive/v$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set -build-mod-req build-tools
pack_set -mod-req boost

_eri=1
_eri2=1
_eri3=1
_max_am=5

pack_set -install-query $_archives/libint-$v-$_eri-$_eri2-$_eri3-$_max_am.tgz

pack_cmd "pushd .. ; ./autogen.sh ; popd"
pack_cmd "../configure --enable-eri=$_eri --enable-eri2=$_eri2 --enable-eri3=$_eri3 --with-max-am=$_max_am" \
	 "--enable-fortran --with-boost=$(pack_get -prefix boost)" \
	 "--prefix=$(pack_get -prefix)"

pack_cmd "make export"
# Store exported library
pack_cmd "mv libint-$v.tgz $_archives/libint-$v-$_eri-$_eri2-$_eri3-$_max_am.tgz"



add_package -directory libint-$v -package libint -archive libint-$v-$_eri-$_eri2-$_eri3-$_max_am.tgz https://github.com/evaleev/libint/archive/v$v.tar.gz

pack_set -lib -lint2 -lstdc++

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set -build-mod-req build-tools
pack_set -mod-req boost
pack_set -mod-req eigen

pack_set -install-query $(pack_get -LD)/libint2.a

pack_cmd "cmake -DENABLE_FORTRAN=1 -DENABLE_MPFR=1" \
	 "-DCMAKE_CXX_COMPILER=$CXX" \
	 "-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)" \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > libint.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store libint.test
