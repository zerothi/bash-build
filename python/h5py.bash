v=2.10.0
add_package -archive h5py-$v.tar.gz \
	    https://github.com/h5py/h5py/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

# Add requirments when creating the module
pack_set -module-requirement numpy \
    -module-requirement hdf5-serial \
    -module-requirement cython

# create dir
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "sed -i -s -e '/H5I_REFERENCE/d' h5py/api_types_hdf5.pxd h5py/h5i.pyx"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py configure" \
    "--hdf5=$(pack_get -prefix hdf5-serial)"

pack_cmd "CFLAGS='$CFLAGS -DH5_USE_110_API' $(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

add_test_package h5py.test
pack_cmd "nosetests --exe h5py > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
