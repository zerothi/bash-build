for v in 1.19.1 ; do
    add_package --archive phono3py-$v.tar.gz \
		https://github.com/atztogo/phono3py/archive/v$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phono3py
    
    # Add requirements when creating the module
    pack_set --module-requirement phonopy
    
    # Install commands that it should run
    pack_cmd "mkdir -p" \
	"$(pack_get --LD)/python$pV/site-packages"
    pack_cmd "CFLAGS='$CFLAGS $FLAG_OMP' $(get_parent_exec) setup.py build"
    pack_cmd "$(get_parent_exec) setup.py install" \
	"--prefix=$(pack_get --prefix)" \
	
done
