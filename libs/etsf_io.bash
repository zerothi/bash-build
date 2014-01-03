v=1.0.4
add_package http://www.etsf.eu/system/files/etsf_io-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement netcdf-serial

pack_set --install-query $(pack_get --install-prefix)/lib/libetsf_io.a

pack_set --command "LIBS='-lnetcdff -lnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz' ./configure" \
    --command-flag "--with-netcdf-prefix=$(pack_get --install-prefix netcdf-serial)" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

# Correct the very strange partition of the module locations
pack_set --command "mv $(pack_get --install-prefix)/include/*/* $(pack_get --install-prefix)/include/" 

