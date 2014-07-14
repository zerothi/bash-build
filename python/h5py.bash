v=2.3.1
add_package https://pypi.python.org/packages/source/h/h5py/h5py-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/site.py

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement hdf5-serial \
    --module-requirement cython

# create dir
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages"
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--hdf5=$(pack_get --install-prefix hdf5-serial)"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe h5py > tmp.test 2>&1 ; echo 'Succes'"
pack_set --command "mv tmp.test $(pack_get --install-query)"
