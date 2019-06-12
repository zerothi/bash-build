v=1.0.4
add_package -package theano -archive Theano-rel-$v.tar.gz \
    https://github.com/Theano/Theano/archive/rel-$v.tar.gz
    
pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/theano-nose
    
pack_set -module-requirement scipy
    
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"
