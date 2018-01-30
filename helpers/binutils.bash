add_package --build generic http://ftp.gnu.org/gnu/binutils/binutils-2.30.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $NO_PIC

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/gprof

pack_cmd "module load $(pack_get --module-name build-tools)"

pack_cmd "../configure --with-sysroot=${SYSROOT-/}" \
	 --enable-install-libiberty \
	 "--prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_cmd "make $(get_make_parallel)"

# Be sure to test
pack_cmd "make check > binutils.test 2>&1 ; echo succes"
pack_set_mv_test binutils.test

pack_cmd "make install"

pack_cmd "module unload $(pack_get --module-name build-tools)"
