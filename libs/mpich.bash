v=3.2

# install HYDRA
add_package http://www.mpich.org/static/downloads/$v/hydra-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --mod-req hwloc

# Fix hydra installation in the same directory as mpich
tmp=$(pack_get --prefix)
pack_set --prefix ${tmp//hydra/mpich}

pack_set --install-query $(pack_get --prefix)/bin/hydra

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure --prefix=$(pack_get --prefix)" \
	 "--with-hwloc-prefix=$(pack_get --prefix hwloc)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Install mpich
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --mod-req hydra

pack_set --install-query $(pack_get --prefix)/bin/mpiexec

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-ibverbs=/usr/include/infiniband"
fi

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-shared --enable-smpcoll" \
	 "--with-pm=hydra $tmp_flags"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
