# Install grace
add_package ftp://plasma-gate.weizmann.ac.il/pub/grace/src/grace5/grace-5.1.25.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/fdf2fit

pack_set --module-opt "--lua-family grace"

pack_set --module-requirement netcdf-serial --module-requirement fftw-2

# The motif library are in the following packages:
# lesstif2-dev

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
    --command-flag "LIBS='-lfftw -lnetcdff -lnetcdf'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req-path)) $CPPFLAGS'" \
    --command-flag "--enable-netcdf" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--enable-grace-home=$(pack_get --prefix)"

# Make commands
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
