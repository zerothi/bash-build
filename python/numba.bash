v=0.13.0
add_package --archive numba-$v.tar.gz \
    https://github.com/numba/numba/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement $(get_parent)
pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmpy
pack_set --module-requirement llvmmath
pack_set --module-requirement numpy[1.7.2]

pack_set --install-query $(pack_get --install-prefix)/bin/numba

pack_set --command "$(get_parent_exec) setup.py build "
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe numba > tmp.test 2>&1 ; echo 'Succes'"
pack_set --command "mv tmp.test $(pack_get --install-query)"

