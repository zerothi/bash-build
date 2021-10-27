add_package --build generic https://ftp.gnu.org/gnu/screen/screen-4.8.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -build-module-requirement build-tools

pack_set --install-query $(pack_get -prefix)/bin/screen

pack_cmd "./configure --prefix $(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
