v=2.5.0
add_package https://pypi.python.org/packages/source/h/h5py/h5py-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement hdf5-serial \
    --module-requirement cython

# create dir
pack_set --command "mkdir -p $(pack_get --LD)/python$pV/site-packages"
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py configure" \
    --command-flag "--hdf5=$(pack_get --prefix hdf5-serial)"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe h5py > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
