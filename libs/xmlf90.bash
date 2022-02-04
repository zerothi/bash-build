add_package https://launchpad.net/xmlf90/trunk/1.5/+download/xmlf90-1.5.4.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libxmlf90.a
pack_set -lib -lxmlf90

# Install commands that it should run
pack_cmd "../configure --prefix $(pack_get -prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
