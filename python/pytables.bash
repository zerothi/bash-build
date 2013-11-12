add_package \
    --package pytables \
    http://downloads.sourceforge.net/project/pytables/pytables/2.4.0/tables-2.4.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/tables

[ "x${pV:0:1}" == "x3" ] && pack_set --host-reject $(hostname)

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement cython \
    --module-requirement hdf5-serial \
    --module-requirement numexpr

    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--hdf5=$(pack_get --install-prefix hdf5-serial)" \
    --command-flag "--cflags='$CFLAGS'"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    
