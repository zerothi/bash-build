v=6.0.0a
add_package --build generic \
    --package gmp --version $v --directory gmp-${v//[a-z]/} \
    https://ftp.gnu.org/gnu/gmp/gmp-$v.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/lib/libgmp.a

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--enable-cxx"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "module unload build-tools"
