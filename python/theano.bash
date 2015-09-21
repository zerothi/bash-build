add_package --archive theano-0.7.tar.gz \
    https://github.com/Theano/Theano/archive/rel-0.7.tar.gz
    
pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/theano
    
pack_set --module-requirement scipy
    
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstall"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
