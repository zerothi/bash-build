for v in 1.7.2 ; do
    add_package http://www.physics.rutgers.edu/pythtb/_downloads/pythtb-$v.tar.gz
    
    pack_set -s $IS_MODULE
    
    pack_set --install-query $(pack_get --LD)/python$pV/site-packages/pythtb.py
    
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement matplotlib
    
    pack_cmd "$_pip_cmd . --prefix=$(pack_get --prefix)"
	
done
