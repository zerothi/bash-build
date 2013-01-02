for http in http://numexpr.googlecode.com/files/numexpr-1.4.2.tar.gz \
    http://numexpr.googlecode.com/files/numexpr-2.0.1.tar.gz ; do
    tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
    
    add_package $http

    pack_set -s $IS_MODULE -s $PRELOAD_MODULE
    pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages
    tmp="$(pack_get --alias)-$(pack_get --version)"
    pack_set --index-alias ${tmp:0:9}
    
    # Add requirments when creating the module
    pack_set $(list --pack-module-reqs numpy) \
	--module-requirement cython
    
    # Install commands that it should run
    pack_set --command "mkdir -p" \
	--command-flag "$(pack_get --install-prefix)/lib/python$pV/site-packages"
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--prefix=$(pack_get --install-prefix)" \
	
done