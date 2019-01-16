add_package https://www.vi-hps.org/upload/packages/otf2/otf2-2.1.1.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/otf2

pack_set --module-requirement build-tools

pack_cmd "./configure --prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
