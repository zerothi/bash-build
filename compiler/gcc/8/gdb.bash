add_package --build generic --package $gcc-gdb \
	    https://ftp.gnu.org/gnu/gdb/gdb-8.2.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --module-requirement gcc[$gcc_v]

pack_set --prefix $(pack_get --prefix gcc[$gcc_v])
pack_set --install-query $(pack_get --prefix)/bin/gdb

# Install commands that it should run
pack_cmd "../configure --prefix $(pack_get --prefix)" \
	 "--with-gmp=$pre" \
	 "--with-mpfr=$pre" \
	 "--with-mpc=$pre" \
	 "--with-isl=$pre" \
	 "--enable-lto"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
