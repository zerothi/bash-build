add_package http://git-core.googlecode.com/files/git-1.8.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/git

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"


pack_install