add_package --build generic http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.7.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix build-tools)/lib/libunistring.a

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
