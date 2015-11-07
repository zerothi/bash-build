for v in 2.2.1 ; do
add_package http://www.tddft.org/programs/APE/sites/default/files/ape-$v.tar.gz

pack_set --install-query $(pack_get --prefix)/bin/ape

pack_set --module-requirement gsl \
    --module-requirement libxc

pack_set --module-opt "--lua-family ape"
# APE does not allow compilation of C-flags too long,
# we simply disable them. :(
pack_cmd "unset CFLAGS"
pack_cmd "unset FCFLAGS"

pack_cmd "./configure" \
     "--with-gsl-prefix=$(pack_get --prefix gsl)" \
     "--with-libxc-prefix=$(pack_get --prefix libxc)" \
     "--prefix=$(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check 2>&1 tmp.test ; echo FORCED"
pack_cmd "make install"
pack_set_mv_test tmp.test

done
