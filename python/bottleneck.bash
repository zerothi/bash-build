for v in 0.7.0 ; do

    add_package --package bottleneck \
	https://pypi.python.org/packages/source/B/Bottleneck/Bottleneck-$v.tar.gz
    
    pack_set -s $IS_MODULE

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages
    
    # Add requirments when creating the module
    pack_set $(list --prefix ' --module-requirement ' numpy cython)
    
    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--prefix=$(pack_get --install-prefix)" \
	
done
