add_package ftp://ftp.gnu.org/gnu/guile/guile-2.0.6.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --install-prefix)/lib/libguile.a

pack_set --module-requirement gmp

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "CPPFLAGS='-I$(pack_get --install-prefix gmp)/include'" \
    --command-flag "LDFLAGS='-L$(pack_get --install-prefix gmp)/lib'" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

pack_install