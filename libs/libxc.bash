v=2.0.2
add_package http://www.tddft.org/programs/octopus/download/libxc/libxc-$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --install-prefix)/lib/libxc.a

pack_set --command "./configure" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

