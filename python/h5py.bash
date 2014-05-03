v=2.3.0
add_package https://pypi.python.org/packages/source/h/h5py/h5py-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement zlib \
    --module-requirement hdf5-serial \
    --module-requirement cython

    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--hdf5=$(pack_get --install-prefix hdf5-serial)"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

