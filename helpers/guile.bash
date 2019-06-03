add_package --build generic ftp://ftp.gnu.org/pub/gnu/guile/guile-2.2.4.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools
pack_set --module-requirement gen-libffi

pack_set --install-query $(pack_get --prefix build-tools)/bin/guile

pack_cmd "./configure --prefix $(pack_get --prefix build-tools)" \
	 "--with-libunistring-prefix=$(pack_get --prefix build-tools)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
