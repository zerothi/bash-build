v=0.4.0
add_package -version $v -package symengine.py -archive symengine.py-$v.tar.gz \
    https://github.com/symengine/symengine.py/archive/v$v.tar.gz
    
pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/theano-nose
    
pack_set -module-requirement symengine
pack_set -module-requirement scipy
    
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
pack_cmd "$(get_parent_exec) setup.py build_ext" \
	 "--inplace --symengine-dir=$(pack_get -prefix symengine)" \
     "install --prefix=$(pack_get -prefix)"
