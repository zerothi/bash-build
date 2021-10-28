v=2.5.4
add_package https://github.com/NCAR/ParallelIO/releases/download/pio_${v//./_}/pio-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR
pack_set -install-query $(pack_get -LD)/libpiof.a
pack_set -lib -lpioc
pack_set -lib[f90] -lpiof -lpioc

pack_set -build-mod-req build-tools
pack_set -mod-req netcdf

pack_cmd "CC=$MPICC FC=$MPIFC cmake -DPIO_USE_PNETCDF_VARD=on" \
	 -DPIO_ENABLE_DOC=off \
	 -DNetCDF_PATH=$(pack_get -prefix netcdf) \
	 -DPnetCDF_PATH=$(pack_get -prefix pnetcdf) \
	 -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) ..

pack_cmd "make $(get_make_parallel)"
# pio tests require around 8 processors to succeed
#pack_cmd "make check > pio.check 2>&1"
pack_cmd "make install"
#pack_store pio.check
