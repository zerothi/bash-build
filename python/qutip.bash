tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
for p in \
    https://qutip.googlecode.com/files/QuTiP-2.1.0.tar.gz \
    https://dl.dropboxusercontent.com/u/2244215/QuTiP-DEV-2.2.0.zip ; do
    
add_package $p

pack_set -s $IS_MODULE

pack_set --host-reject thul --host-reject surt \
    --host-reject slid --host-reject ntch

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(lc $(pack_get --alias))

# Add requirments when creating the module
pack_set --module-requirement scipy \
    --module-requirement cython \
    --module-requirement matplotlib
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    
done
