v=0.11.0
add_package https://pypi.python.org/packages/source/n/numba/numba-$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmpy
pack_set --module-requirement llvmmath
pack_set --module-requirement numpy

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
