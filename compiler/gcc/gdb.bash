add_package -build generic https://ftp.gnu.org/gnu/gdb/gdb-13.1.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/gdb

# Install commands that it should run
pack_cmd "../configure --prefix $(pack_get -prefix)" \
	 "--with-gmp=$(pack_get -prefix gmp)" \
	 "--with-mpfr=$(pack_get -prefix mpfr)" \
	 "--with-mpc=$(pack_get -prefix mpc)" \
	 "--with-isl=$(pack_get -prefix isl)" \
	 "--enable-lto"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
