add_package http://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libglpk.a

pack_cmd "../configure --prefix $(pack_get -prefix) --enable-shared --with-cxx"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

