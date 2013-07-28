# Install grace
add_package ftp://plasma-gate.weizmann.ac.il/pub/grace/src/grace5/grace-5.1.23.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/fdf2fit

pack_set $(list --pack-module-reqs netcdf-serial fftw-2)

# The motif library are in the following packages:
# lesstif2-dev

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "LDFLAGS='$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))'" \
    --command-flag "LIBS='-lfftw -lnetcdff -lnetcdf'" \
    --command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --module-requirement)) $CPPFLAGS'" \
    --command-flag "--enable-netcdf" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-grace-home=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 
