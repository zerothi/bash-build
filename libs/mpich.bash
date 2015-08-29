v=3.1.4
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/mpiexec

pack_set --host-reject $(get_hostname)

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-shared --enable-smpcoll"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"


## Also install HYDRA
add_package http://www.mpich.org/static/downloads/$v/hydra-$v.tar.gz

pack_set --prefix $(pack_get --prefix mpich)
pack_set --mod-req mpich

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/mpiexec

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-shared --enable-smpcoll"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
