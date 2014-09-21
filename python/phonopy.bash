[ "x${pV:0:1}" == "x3" ] && return 0

for v in 1.8.4.1 ; do
    add_package http://downloads.sourceforge.net/project/phonopy/phonopy/phonopy-1.8/phonopy-$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phonopy
        
    # Add requirements when creating the module
    pack_set --module-requirement numpy \
	--module-requirement scipy
    
    # Install commands that it should run
    pack_set --command "mkdir -p" \
	--command-flag "$(pack_get --library-path)/python$pV/site-packages"
    pack_set --command "$(get_parent_exec) setup.py build"
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--home=$(pack_get --prefix)" \
	
done
