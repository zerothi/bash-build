v=1.1.6
add_package -directory libint-release-${v//./-} -package libint -archive libint-$v.tar.gz https://github.com/evaleev/libint/archive/release-${v//./-}.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL
pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/lib/libint.a

pack_cmd "pushd .. ; aclocal -I lib/autoconf ; autoconf ; popd"
pack_cmd "../configure --enable-deriv --enable-r12 --prefix=$(pack_get -prefix)"

pack_cmd "make"
pack_cmd "make install"
