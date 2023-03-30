v=2023-02-03
add_package -archive seacas-$v.tar.gz \
	    -package seacas \
	    -version ${v//-/.} \
	    https://github.com/sandialabs/seacas/archive/refs/tags/v$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set $(list -p '-mod-req ' mpi netcdf parmetis fmt)
pack_set -install-query $(pack_get -LD)/libexodus.a
pack_set -lib -lseacas
pack_set -lib[exodus] -lexodusii

# Install commands that it should run
# Edit cmake-config
pack_cmd "sed -i -e 's:^\(NETCDF_PATH=\).*:\1$(pack_get -prefix netcdf):' ../cmake-config"
pack_cmd "sed -i -e 's:^\(PNETCDF_PATH=\).*:\1$(pack_get -prefix pnetcdf):' ../cmake-config"
pack_cmd "sed -i -e 's:^\(HDF5_PATH=\).*:\1$(pack_get -prefix hdf5):' ../cmake-config"
pack_cmd "sed -i -e 's:^\(METIS_PATH=\).*:\1$(pack_get -prefix parmetis):' ../cmake-config"
pack_cmd "sed -i -e 's:^\(PARMETIS_PATH=\).*:\1$(pack_get -prefix parmetis):' ../cmake-config"

pack_cmd "INSTALL_PATH=$(pack_get -prefix) MPI=ON" \
	"FMT_PATH=$(pack_get -prefix fmt)" \
	 "COMPILER=$(get_c -n) ../cmake-config" \
	 -DMETIS_LIBRARY_DIRS=$(pack_get -LD parmetis) \
	 -DMETIS_INCLUDE_DIRS=$(pack_get -prefix parmetis)/include \
	 -DParMETIS_LIBRARY_DIRS=$(pack_get -LD parmetis) \
	 -DParMETIS_INCLUDE_DIRS=$(pack_get -prefix parmetis)/include \
	 -Dfmt_INCLUDE_DIRS=$(pack_get -prefix fmt)/include
	 
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > seacas.test 2>&1 || echo forced"
pack_cmd "make install"
pack_store seacas.test
