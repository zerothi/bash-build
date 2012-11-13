tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://qutip.googlecode.com/files/QuTiP-2.1.0.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(lc $(pack_get --alias))

# Add requirments when creating the module
pack_set --module-requirement $(get_parent) \
    --module-requirement cython \
    --module-requirement numpy \
    --module-requirement scipy \
    --module-requirement matplotlib
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    
pack_install