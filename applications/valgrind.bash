add_package http://valgrind.org/downloads/valgrind-3.10.1.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --prefix)/bin/valgrind

pack_set --module-opt "--lua-family valgrind"
pack_set --module-requirement openmpi

pack_set --command "../configure --with-mpicc=$MPICC" \
    --command-flag "--enable-only64bit" \
    --command-flag "--prefix=$(pack_get --prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias) 
