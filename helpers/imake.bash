add_package --build generic https://www.x.org/releases/individual/util/imake-1.0.7.tar.bz2

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR -s $BUILD_TOOLS

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/imake

pack_cmd "../configure --prefix $(pack_get --prefix)"

# Make commands (no tests available)
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
