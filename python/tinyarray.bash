add_package https://pypi.python.org/packages/source/t/tinyarray/tinyarray-1.0.5.tar.gz
    
pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages
    
pack_set --module-requirement numpy \
    --module-requirement cython

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"