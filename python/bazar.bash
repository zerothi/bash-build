tmp=$(pack_get --version $(get_parent))

# We only accept bzr installation on python 2.x
if [ "${tmp:0:1}" == "2" ]; then
    tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
    add_package https://launchpad.net/bzr/2.5/2.5.1/+download/bzr-2.5.1.tar.gz
    
    pack_set -s $IS_MODULE
    
    pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)
    
    pack_set --install-query $(pack_get --install-prefix)/bin/bzr
    
    # Add requirments when creating the module
    pack_set --module-requirement $(get_parent) \
	--module-requirement cython
    
    
    # Install commands that it should run
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--prefix=$(pack_get --install-prefix)" \
	
fi