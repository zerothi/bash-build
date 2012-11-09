# Install gnuplot, which is a simple library
add_package ftp://plasma-gate.weizmann.ac.il/pub/grace/src/grace5/grace-5.1.23.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/xmgrace

pack_set --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement pnetcdf \
    --module-requirement netcdf

# The motif library are in the following packages:
# lesstif2-dev

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "CC=${MPICC}" \
    --command-flag "LDFLAGS='$($(pack_get --install-prefix netcdf)/bin/nc-config --libs)'" \
    --command-flag "CPPFLAGS='$($(pack_get --install-prefix netcdf)/bin/nc-config --cflags) $CPPFLAGS'" \
    --command-flag "--enable-netcdf --without-fftw" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "--enable-grace-home=$(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "install"

pack_install