v=0.15.1
add_package --archive numba-$v.tar.gz \
    https://github.com/numba/numba/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmpy
pack_set --module-requirement llvmmath

pack_set --install-query $(pack_get --prefix)/bin/numba

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages/"

pack_cmd "$(get_parent_exec) setup.py build "
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package
pack_cmd "nosetests --exe numba > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

