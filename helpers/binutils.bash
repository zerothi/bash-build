add_package --build generic http://ftp.gnu.org/gnu/binutils/binutils-2.26.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/gprof

pack_cmd "module load $(pack_get --module-name build-tools)"

pack_cmd "../configure --with-sysroot=${SYSROOT-/}" \
	 "--prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "module unload $(pack_get --module-name build-tools)"
