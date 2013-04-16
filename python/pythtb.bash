
tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
for v in 1.6.2 ; do
    add_package http://www.physics.rutgers.edu/pythtb/_downloads/pythtb-$v.tar.gz
    
    pack_set -s $IS_MODULE
    pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/lib/python/pythtb.py
        
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement matplotlib
    
    # Install commands that it should run
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--home=$(pack_get --install-prefix)" \
	
done