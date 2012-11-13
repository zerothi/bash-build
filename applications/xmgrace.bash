# Install grace, which is a simple library
add_package ftp://plasma-gate.weizmann.ac.il/pub/grace/src/grace5/grace-5.1.23.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/xmgrace

pack_set --module-requirement netcdf-serial \
    --module-requirement fftw-2


# The motif library are in the following packages:
# lesstif2-dev

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "LDFLAGS='$($(pack_get --install-prefix netcdf-serial)/bin/nc-config --libs)'" \
    --command-flag "LIBS='$(pack_get --install-prefix fftw-2)/lib/libfftw.a'" \
    --command-flag "CPPFLAGS='$($(pack_get --install-prefix netcdf-serial)/bin/nc-config --cflags) -I$(pack_get --install-prefix fftw-2)/include $CPPFLAGS'" \
    --command-flag "--enable-netcdf" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-grace-home=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install