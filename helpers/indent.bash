add_package --build generic ftp://ftp.gnu.org/pub/gnu/indent/indent-2.2.12.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix build-tools)/bin/indent

pack_cmd "./configure --prefix $(pack_get --prefix build-tools)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
