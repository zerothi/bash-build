add_package http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-2.2b.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/mpicc

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-ibverbs=/usr/include/infiniband"
else
    # MVAPICH requires infiniband
    pack_set --host-reject $(get_hostname)
fi

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-threads=runtime" \
	 "--enable-shared --enable-smpcoll" \
	 "--with-pm=hydra $tmp_flags"

# We first need to assert the postdeps are correct
# Sadly this comes about in certain environments.
# But I am not fully sure why it happens...
for f in libtool config.lt config.status
do
    pack_cmd "sed -i -e 's/-l -l / /' $f"
done

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"



new_build --name internal-mvapich \
  --installation-path $(build_get --ip)/$(pack_get --package)/$(pack_get --version) \
  --module-path $(build_get -mp)-mvapich \
  --build-path $(build_get -bp) \
  --build-module-path "$(build_get -bmp)" \
  --build-installation-path "$(build_get -bip)" \
  --source $(build_get --source) \
  $(list -p '--default-module ' $(build_get --default-module) mvapich)
