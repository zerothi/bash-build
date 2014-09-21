for v in 2.2.0 ; do
add_package http://www.tddft.org/programs/APE/sites/default/files/ape-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ape

pack_set --module-requirement gsl \
    --module-requirement libxc

pack_set --module-opt "--lua-family ape"

pack_set --command "./configure" \
    --command-flag "--with-gsl-prefix=$(pack_get --prefix gsl)" \
    --command-flag "--with-libxc-prefix=$(pack_get --prefix libxc)" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make check 2>&1 tmp.test"
pack_set --command "make install"
pack_set_mv_test tmp.test

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

done
