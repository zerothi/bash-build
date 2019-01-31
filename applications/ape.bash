v=2.3.0
add_package http://www.tddft.org/programs/octopus/download/APE/$v/ape-$v.tar.gz

pack_set -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/ape

pack_set --module-requirement gsl \
    --module-requirement libxc

pack_set --module-opt "--lua-family ape"
# APE does not allow compilation of C-flags too long,
# we simply disable them. :(
pack_cmd "unset FPP"
pack_cmd "unset CPP"

pack_cmd "../configure FCFLAGS='$FCFLAGS -ffree-line-length-none'" \
     "--with-gsl-prefix=$(pack_get --prefix gsl)" \
     "--with-libxc-prefix=$(pack_get --prefix libxc)" \
     "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check 2>&1 > ape.test ; echo FORCED"
pack_cmd "make install"
pack_set_mv_test ape.test
