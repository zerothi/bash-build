add_package --build generic --alias libxml2 --package libxml2 \
    https://git.gnome.org/browse/libxml2/snapshot/libxml2-2.9.1.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement gen-zlib

pack_set --install-query $(pack_get --prefix)/include/xml2.h

# Preload all tools for creating the configure script
tmp="$(pack_get --mod-req-all libtool) $(pack_get --module-name libtool)"
pack_set --command "module load $tmp"

# Create configure
pack_set --command "./autogen.sh"

# Preload all tools for creating the configure script
pack_set --command "module unload $tmp"

pack_set --command "./configure --prefix $(pack_get --prefix)" \
    --command-flag "--with-zlib=$(pack_get --prefix gen-zlib)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test
