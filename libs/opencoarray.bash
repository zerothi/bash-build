v=1.8.4
add_package -package opencoarrays https://github.com/sourceryinstitute/opencoarrays/releases/download/$v/OpenCoarrays-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --mod-req mpi

if $(is_c intel) ; then
    pack_set --host-reject $(get_hostname)
fi
# Only allow opencoarray installation for gcc >= 6.1
if [ $(vrs_cmp $(get_c --version) 6.1.0) -lt 0 ]; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --LD)/libcaf_mpi.a

pack_cmd "module load $(pack_get -m cmake)"

# Install commands that it should run
pack_cmd "CC=$MPICC FC=$MPIFC cmake" \
	 "-DCMAKE_INSTALL_PREFIX=$(pack_get --prefix) .."

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > tmp.test 2>&1 || echo 'Forced success'"
pack_cmd "make install"
pack_set_mv_test tmp.test

pack_cmd "module unload $(pack_get -m cmake)"
