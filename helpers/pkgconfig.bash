add_package -build generic https://pkg-config.freedesktop.org/releases/pkg-config-0.29.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set -prefix $(pack_get -prefix build-tools)

pack_set -install-query $(pack_get -prefix)/bin/pkg-config

# Install commands that it should run
pack_cmd "../configure --prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

