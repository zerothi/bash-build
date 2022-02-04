for v in 1.16.3 ; do
    add_package --archive spglib-$v.tar.gz --package pyspglib \
        https://github.com/spglib/spglib/archive/v$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set -install-query $(pack_get -prefix)/lib/python$pV/site-packages/spglib
    
    # Add requirements when creating the module
    pack_set -module-requirement numpy
    
    # Install commands that it should run
    pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
    pack_cmd "cd python"
    pack_cmd "CFLAGS='$CFLAGS $FLAG_OMP' $_pip_cmd . --prefix=$(pack_get -prefix)"
	
done
