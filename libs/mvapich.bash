v=2.3.7
add_package --package mvapich --version $v \
    http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/mpicc

pack_set -module-opt "-set-ENV MPICC=mpicc"
pack_set -module-opt "-set-ENV CMAKE_C_COMPILER=mpicc"
pack_set -module-opt "-set-ENV MPICXX=mpicxx"
pack_set -module-opt "-set-ENV CMAKE_CXX_COMPILER=mpicxx"
pack_set -module-opt "-set-ENV MPIF77=mpif77"
pack_set -module-opt "-set-ENV MPIF90=mpif90"
pack_set -module-opt "-set-ENV MPIFC=mpifort"
pack_set -module-opt "-set-ENV CMAKE_Fortran_COMPILER=mpifort"
# We want to make it easy to create compiler flags for cmake-builds
#pack_set -module-opt "-set-ENV MPI_CMAKE='-DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpifort'"

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



new_build --name _internal-mvapich \
  --installation-path $(build_get --ip)/$(pack_get --package)/$(pack_get --version) \
  --module-path $(build_get -mp)-mvapich \
  --build-path $(build_get -bp) \
  --build-module-path "$(build_get -bmp)" \
  --build-installation-path "$(build_get -bip)" \
  --source $(build_get --source) \
  $(list -p '--default-module ' $(build_get --default-module) mvapich)
