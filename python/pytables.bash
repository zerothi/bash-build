tmp=$(hostname)
[ "${tmp:0:2}" != "n-" ] && return 0

tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://downloads.sourceforge.net/project/pytables/pytables/2.4.0/tables-2.4.0.tar.gz

pack_set --alias pytables
pack_set --package pytables

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/soteu

# Add requirments when creating the module
pack_set --module-requirement $(get_parent) \
    --module-requirement cython \
    --module-requirement zlib \
    --module-requirement hdf5-serial \
    --module-requirement numpy \
    --module-requirement numexpr-2

    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--hdf5=$(pack_get --install-prefix hdf5-serial)" \
    --command-flag "--cflags='$CFLAGS'"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    
pack_install