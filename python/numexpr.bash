# old_v 
for v in 1.4.2 2.2.2 ; do
    [ "x${pV:0:1}" == "x3" ] && [ "x$v" == "x1.4.2" ] && continue

    add_package http://numexpr.googlecode.com/files/numexpr-$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages
    
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement cython
    
    # Install commands that it should run
    pack_set --command "mkdir -p" \
	--command-flag "$(pack_get --install-prefix)/lib/python$pV/site-packages"
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--prefix=$(pack_get --install-prefix)"
    
done
