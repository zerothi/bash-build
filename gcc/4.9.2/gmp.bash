v=6.0.0a
add_package --build generic \
	    --package gmp --version $v --directory gmp-${v//[a-z]/} \
	    https://ftp.gnu.org/gnu/gmp/gmp-$v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/lib/libgmp.a

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "../configure" \
         "--prefix $(pack_get --prefix)" \
         "--enable-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload build-tools"
