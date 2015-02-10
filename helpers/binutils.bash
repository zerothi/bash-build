add_package --build generic http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/gprof

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
