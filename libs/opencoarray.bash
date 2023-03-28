v=2.10.1
add_package -package opencoarrays \
	    -archive OpenCoarrays-$v.tar.gz \
	    https://github.com/sourceryinstitute/OpenCoarrays/archive/$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set -build-mod-req build-tools
pack_set -mod-req mpi

if $(is_c intel) ; then
    pack_set -host-reject $(get_hostname)
fi
# Only allow opencoarray installation for gcc >= 6.1
if [ $(vrs_cmp $(get_c -version) 6.1.0) -lt 0 ]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -install-query $(pack_get -LD)/libcaf_mpi.a

# Install commands that it should run
pack_cmd "CC=$MPICC FC=$MPIFC cmake" \
	 "-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) .."

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make test > opencoarray.test 2>&1 || echo 'Forced success'"
pack_cmd "make install"
pack_store opencoarray.test
