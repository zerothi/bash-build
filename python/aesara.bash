v=2.8.12
add_package -package aesara -archive aesara-rel-$v.tar.gz \
    https://github.com/aesara-devs/aesara/archive/refs/tags/rel-$v.tar.gz
    
pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/aesara-nose
    
pack_set -module-requirement scipy
    
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"
