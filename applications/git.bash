add_package http://git-core.googlecode.com/files/git-1.8.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --module-opt "--lua-family git"

pack_set --install-query $(pack_get --install-prefix)/bin/git
pack_set --module-requirement zlib

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "CFLAGS='$CFLAGS $(list --LDFLAGS -Wlrpath zlib)'" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--with-zlib=$(pack_get --install-prefix zlib)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

pack_install

