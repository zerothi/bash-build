add_package --build generic http://ftp.gnu.org/gnu/binutils/binutils-2.31.1.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $NO_PIC -s $BUILD_TOOLS

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/gprof

pack_cmd "../configure --with-sysroot=${SYSROOT-/}" \
	 --enable-gold=yes \
	 --enable-ld=yes \
	 --enable-lto=yes \
	 --enable-shared \
	 --enable-install-libiberty \
	 "--prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_cmd "make $(get_make_parallel)"

# Be sure to test
pack_cmd "make check > binutils.test 2>&1 ; echo succes"
pack_set_mv_test binutils.test

pack_cmd "make install"
