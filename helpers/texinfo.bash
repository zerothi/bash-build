add_package --build generic http://ftp.gnu.org/gnu/texinfo/texinfo-5.2.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix build-tools)/bin/texinfo

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix build-tools)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
