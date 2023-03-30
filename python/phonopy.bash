for v in 2.18.0 ; do
    add_package --archive phonopy-$v.tar.gz \
        https://github.com/phonopy/phonopy/archive/v$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phonopy
    
    # Add requirements when creating the module
    pack_set --module-requirement scipy
    pack_set --module-requirement matplotlib
    pack_set --module-requirement h5py
    
    # Install commands that it should run
    pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"
    pack_cmd "CFLAGS='$CFLAGS $FLAG_OMP' $_pip_cmd . --prefix=$(pack_get -prefix)"
	
done
