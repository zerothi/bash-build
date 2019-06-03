for v in 2.1.3 ; do
    add_package --archive phonopy-$v.tar.gz \
        https://github.com/atztogo/phonopy/archive/v$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phonopy
    
    # Add requirements when creating the module
    pack_set --module-requirement scipy
    pack_set --module-requirement matplotlib
    pack_set --module-requirement h5py
    
    # Install commands that it should run
    pack_cmd "mkdir -p" \
	"$(pack_get --LD)/python$pV/site-packages"
    pack_cmd "CFLAGS='$CFLAGS $FLAG_OMP' $(get_parent_exec) setup.py build"
    pack_cmd "$(get_parent_exec) setup.py install" \
	"--prefix=$(pack_get --prefix)" \
	
done
