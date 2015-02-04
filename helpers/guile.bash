add_package --build generic ftp://ftp.gnu.org/pub/gnu/guile/guile-2.0.11.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement build-tools
pack_set --module-requirement gen-libffi

pack_set --install-query $(pack_get --prefix build-tools)/bin/guile

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)" \
    --command-flag "--with-libunistring-prefix=$(pack_get --prefix build-tools)" \
    --command-flag "--with-libgmp-prefix=$(pack_get --prefix gmp)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
