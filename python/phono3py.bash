for v in 2.0.0 ; do
    add_package --archive phono3py-$v.tar.gz \
		https://github.com/atztogo/phono3py/archive/v$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phono3py
    
    # Add requirements when creating the module
    pack_set --module-requirement phonopy
    
    # Install commands that it should run
    pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"
    pack_cmd "CFLAGS='$CFLAGS $FLAG_OMP' $_pip_cmd . --prefix=$(pack_get -prefix)"
	
done
