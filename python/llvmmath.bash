v=0.1.1
add_package https://pypi.python.org/packages/source/l/llvmmath/llvmmath-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/llvmmath

pack_set --module-requirement llvmpy
pack_set --module-requirement numpy[1.7.2]

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe llvmmath > tmp.test 2>&1"
pack_set --command "mv tmp.test $(pack_get --install-query)"
