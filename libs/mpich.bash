v=3.3
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --mod-req hwloc

pack_set --install-query $(pack_get --prefix)/bin/mpicc

tmp_flags=
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-ibverbs=/usr/include/infiniband"
fi

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "unset MPIF77"
pack_cmd "unset MPIF90"
pack_cmd "unset MPIFC"
pack_cmd "unset MPICC"
pack_cmd "unset MPICXX"
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-threads=runtime" \
	 "--enable-shared --enable-smpcoll" \
	 "--with-pm=hydra $tmp_flags" \
	 "--with-hwloc-prefix=$(pack_get --prefix hwloc)"

# We first need to assert the postdeps are correct
# Sadly this comes about in certain environments.
# But I am not fully sure why it happens...
for f in libtool config.lt config.status
do
    pack_cmd "sed -i -e 's/-l -l / /' $f"
done

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"



new_build --name internal-mpich \
  --installation-path $(build_get --ip)/$(pack_get --package)/$(pack_get --version) \
  --module-path $(build_get -mp)-mpich \
  --build-path $(build_get -bp) \
  --build-module-path "$(build_get -bmp)" \
  --build-installation-path "$(build_get -bip)" \
  --source $(build_get --source) \
  $(list -p '--default-module ' $(build_get --default-module) mpich)

# install HYDRA
# MPICH installs its own, minimal hydra.
# However, here we would like to use hwloc
add_package http://www.mpich.org/static/downloads/$v/hydra-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --mod-req mpich

# Fix hydra installation in the same directory as mpich
tmp=$(pack_get --prefix)
pack_set --prefix $(pack_get --prefix mpich)

pack_set --install-query $(pack_get --prefix)/custom.hydra

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "unset MPIF77"
pack_cmd "unset MPIF90"
pack_cmd "unset MPIFC"
pack_cmd "unset MPICC"
pack_cmd "unset MPICXX"
pack_cmd "../configure --prefix=$(pack_get --prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-threads=runtime" \
	 "--enable-shared $tmpflags" \
	 "--with-hwloc-prefix=$(pack_get --prefix hwloc)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "touch $(pack_get --prefix)/custom.hydra"
