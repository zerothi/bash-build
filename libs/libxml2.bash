add_package ftp://xmlsoft.org/libxml2/libxml2-2.9.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libxml2.so

# Add requirments when creating the module
pack_set --module-requirement zlib

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix $(pack_get --prefix)" \
    --command-flag "--with-python=no" \
    --command-flag "--with-zlib=$(pack_get --prefix zlib)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check > tmp.test 2>&1"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_set --command "pushd $(pack_get --prefix)/include"
pack_set --command "ln -s libxml2/libxml"
pack_set --command "popd"
