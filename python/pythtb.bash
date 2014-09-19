[ "x${pV:0:1}" == "x3" ] && return 0

for v in 1.6.2 ; do
    add_package http://www.physics.rutgers.edu/pythtb/_downloads/pythtb-$v.tar.gz
    
    pack_set -s $IS_MODULE

    pack_set --install-query $(pack_get --library-path)/python/pythtb.py
        
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement matplotlib
    
    pack_set --command "$(get_parent_exec) setup.py build"
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--home=$(pack_get --install-prefix)" \
	
done
