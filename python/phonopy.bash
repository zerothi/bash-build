[ "x${pV:0:1}" == "x3" ] && return 0

for v in 1.8.4.1 1.9.4 ; do
    add_package http://downloads.sourceforge.net/project/phonopy/phonopy/phonopy-${v:0:3}/phonopy-$v.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    pack_set --install-query $(pack_get --prefix)/bin/phonopy
    
    # Add requirements when creating the module
    pack_set --module-requirement scipy
    
    # Install commands that it should run
    pack_cmd "mkdir -p" \
	"$(pack_get --LD)/python$pV/site-packages"
    pack_cmd "$(get_parent_exec) setup.py build"
    pack_cmd "$(get_parent_exec) setup.py install" \
	"--home=$(pack_get --prefix)" \
	
done
