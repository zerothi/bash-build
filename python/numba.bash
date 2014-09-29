v=0.13.4
add_package --archive numba-$v.tar.gz \
    https://github.com/numba/numba/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmpy
pack_set --module-requirement llvmmath

pack_set --install-query $(pack_get --prefix)/bin/numba

pack_set --command "$(get_parent_exec) setup.py build "
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe numba > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test

