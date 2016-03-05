add_package http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-2.2b.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/mpicc

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-ibverbs=/usr/include/infiniband"
fi

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-threads=runtime" \
	 "--enable-shared --enable-smpcoll" \
	 "--with-pm=hydra $tmp_flags"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
