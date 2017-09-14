v=5.18.12
add_package --build generic http://ftp.gnu.org/gnu/autogen/rel$v/autogen-$v.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools

pack_set --install-query $(pack_get --prefix build-tools)/bin/autogen

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix build-tools)" \
	 "--with-libguile=$(pack_get --prefix build-tools)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
