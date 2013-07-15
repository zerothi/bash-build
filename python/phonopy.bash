[ "x${pV:0:1}" == "x3" ] && return 0

for v in 1.7 ; do
    add_package http://downloads.sourceforge.net/project/phonopy/phonopy/phonopy-1.7/phonopy-$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE
    pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$IpV/$(get_c)

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/bin/phonopy
        
    # Add requirements when creating the module
    pack_set --module-requirement numpy \
	--module-requirement scipy
    
    # Install commands that it should run
    pack_set --command "mkdir -p" \
	--command-flag "$(pack_get --install-prefix)/lib/python$pV/site-packages"
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--home=$(pack_get --install-prefix)" \
	
done
