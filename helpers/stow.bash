add_package --build generic https://ftp.gnu.org/gnu/stow/stow-2.3.0.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/stow

pack_cmd "./configure --prefix=$(pack_get -prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
