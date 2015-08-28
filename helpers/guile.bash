add_package --build generic ftp://ftp.gnu.org/pub/gnu/guile/guile-2.0.11.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools
pack_set --module-requirement gen-libffi

pack_set --install-query $(pack_get --prefix build-tools)/bin/guile

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix build-tools)" \
	 "--with-libunistring-prefix=$(pack_get --prefix build-tools)" \
	 "--with-libgmp-prefix=$(pack_get --prefix gmp)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
