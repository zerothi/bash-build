[ "x${pV:0:1}" == "x3" ] && return 0

for p in \
    https://qutip.googlecode.com/files/QuTiP-2.2.0.tar.gz ; do
#    https://dl.dropboxusercontent.com/u/2244215/QuTiP-DEV-2.2.0.zip ; do

#    https://qutip.googlecode.com/files/QuTiP-2.2.0.tar.gz \
    
add_package --directory qutip-2.2.0 $p

pack_set -s $IS_MODULE

pack_set $(list --prefix '--host-reject ' ntch zeroth hemera eris)

p_name=$(lc $(pack_get --alias))
p_name=${p_name//-DEV/}

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$p_name

# Add requirments when creating the module
pack_set --module-requirement scipy \
    --module-requirement cython \
    --module-requirement matplotlib

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    
done
