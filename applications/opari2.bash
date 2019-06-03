add_package https://www.vi-hps.org/upload/packages/opari2/opari2-2.0.4.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/opari2

pack_set --module-requirement build-tools

pack_cmd "./configure --prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
