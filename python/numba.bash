add_package https://pypi.python.org/packages/source/n/numba/numba-0.17.0.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement cython
pack_set --module-requirement cffi
pack_set --module-requirement llvmlite

pack_set --install-query $(pack_get --prefix)/bin/numba

pack_set --command "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages/"

pack_set --command "$(get_parent_exec) setup.py build "
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe numba > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

