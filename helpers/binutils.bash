add_package -build generic http://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $NO_PIC

pack_set -prefix $(pack_get -prefix build-tools)
pack_set -build-mod-req build-tools

pack_set -install-query $(pack_get -prefix)/bin/gprof

pack_cmd "../configure --with-sysroot=${SYSROOT-/}" \
	 --enable-gold=yes \
	 --enable-ld=yes \
	 --enable-lto=yes \
	 --enable-shared \
	 --enable-plugins \
	 --enable-install-libiberty \
	 "--prefix $(pack_get -prefix)"

# Make commands (no tests available)
pack_cmd "make $(get_make_parallel) tooldir=$(pack_get -prefix)"

# Be sure to test
pack_cmd "make check > binutils.test 2>&1 || echo forced"
pack_store binutils.test

pack_cmd "make tooldir=$(pack_get -prefix) install"
