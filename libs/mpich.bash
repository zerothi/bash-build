v=3.3
add_package http://www.mpich.org/static/downloads/$v/mpich-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# 3.3 has a problem using an external hwloc! :(
tmp_flags=
pack_set -install-query $(pack_get -prefix)/bin/mpicc

pack_set --module-opt "--set-ENV MPICC=mpicc"
pack_set --module-opt "--set-ENV MPICXX=mpicxx"
pack_set --module-opt "--set-ENV MPIF77=mpif77"
pack_set --module-opt "--set-ENV MPIF90=mpif90"
pack_set --module-opt "--set-ENV MPIFC=mpifort"

if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-ibverbs=/usr/include/infiniband"
fi
pack_set -mod-req hwloc
tmp_flags="$tmp_flags --with-hwloc=$(pack_get -prefix hwloc)"

if [[ $(pack_installed ucx) ]]; then
    pack_set -mod-req ucx
    tmp_flags="$tmp_flags --with-ucx=$(pack_get -prefix ucx)"
fi

[[ -e /usr/include/slurm/pmi2.h ]] && tmp_flags="$tmp_flags --with-slurm --with-pmi=/usr"

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "unset MPIF77"
pack_cmd "unset MPIF90"
pack_cmd "unset MPIFC"
pack_cmd "unset MPICC"
pack_cmd "unset MPICXX"
pack_cmd "../configure" \
	 "--prefix=$(pack_get -prefix)" \
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



new_build -name _internal-mpich \
  -installation-path $(build_get -ip)/$(pack_get -package)/$(pack_get -version) \
  -module-path $(build_get -mp)-mpich \
  -build-path $(build_get -bp) \
  -build-module-path "$(build_get -bmp)" \
  -build-installation-path "$(build_get -bip)" \
  -source $(build_get -source) \
  $(list -p '-default-module ' $(build_get -default-module) mpich)


return 0
# install HYDRA
# MPICH installs its own, minimal hydra.
# However, here we would like to use hwloc
add_package http://www.mpich.org/static/downloads/$v/hydra-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -mod-req mpich

# Fix hydra installation in the same directory as mpich
tmp=$(pack_get -prefix)
pack_set -prefix $(pack_get -prefix mpich)

pack_set -install-query $(pack_get -prefix)/custom.hydra

pack_cmd "unset F90"
pack_cmd "unset F90FLAGS"
pack_cmd "unset MPIF77"
pack_cmd "unset MPIF90"
pack_cmd "unset MPIFC"
pack_cmd "unset MPICC"
pack_cmd "unset MPICXX"
pack_cmd "../configure --prefix=$(pack_get -prefix)" \
	 "--enable-fortran=all --enable-cxx" \
	 "--enable-threads=runtime" \
	 "--enable-shared $tmpflags" 

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
pack_cmd "touch $(pack_get -prefix)/custom.hydra"
