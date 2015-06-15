add_package --build generic http://ftp.gnu.org/gnu/binutils/binutils-2.25.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/gprof

pack_set --command "module load $(pack_get --module-name build-tools)"

pack_set --command "../configure --with-sysroot=${SYSROOT-/}" \
    --command-flag "--prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_set --command "module unload $(pack_get --module-name build-tools)"
