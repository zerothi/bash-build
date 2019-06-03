add_package --build generic ftp://ftp.gnu.org/pub/gnu/shtool/shtool-2.0.8.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix build-tools)/bin/shtool

pack_cmd "./configure --prefix $(pack_get --prefix build-tools)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
