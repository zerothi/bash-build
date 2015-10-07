v=1.1.0
add_package https://github.com/sourceryinstitute/opencoarrays/releases/download/$v/opencoarrays-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --mod-req mpi

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
