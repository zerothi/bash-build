v=1.0.4
add_package http://www.etsf.eu/system/files/etsf_io-$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --module-requirement netcdf

pack_set --install-query $(pack_get --install-prefix)/lib/libetsf_io.a

pack_set --command "CC='$MPICC' FC='$MPIFC' LIBS='-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz' ./configure" \
    --command-flag "--with-netcdf-prefix=$(pack_get --install-prefix netcdf)" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

# Correct a bug in the test library
pack_set --command "sed -i -e 's:len = 256:len = dims(1):g' tests/group_level/tests_module.f90"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make check"
pack_set --command "make install"

# Correct the very strange partition of the module locations
pack_set --command "mv $(pack_get --install-prefix)/include/*/* $(pack_get --install-prefix)/include/" 

