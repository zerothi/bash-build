add_package --build generic http://ftp.gnu.org/gnu/texinfo/texinfo-6.4.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --prefix $(pack_get --prefix build-tools)

pack_set --install-query $(pack_get --prefix)/bin/makeinfo

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
