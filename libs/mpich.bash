v=3.1.4
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/mpiexec

pack_set --host-reject $(get_hostname)

pack_set --command "unset F90"
pack_set --command "unset F90FLAGS"
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--enable-fortran=all --enable-cxx" \
    --command-flag "--disable-shared --enable-smpcoll"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"


## Also install HYDRA
add_package http://www.mpich.org/static/downloads/$v/hydra-$v.tar.gz

pack_set --prefix $(pack_get --prefix mpich)
pack_set --mod-req mpich

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/mpiexec

pack_set --command "unset F90"
pack_set --command "unset F90FLAGS"
pack_set --command "../configure" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--enable-fortran=all --enable-cxx" \
    --command-flag "--disable-shared --enable-smpcoll"

pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
