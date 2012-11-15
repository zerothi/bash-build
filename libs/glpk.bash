return 0
add_package http://ftp.gnu.org/gnu/glpk/glpk-4.47.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libglpk.a

pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --install-prefix)" \
    --command-flag "--enable-shared --with-cxx"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install
