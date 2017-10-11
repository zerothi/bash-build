v=0.1.2
add_package --archive llvmmath-$v.tar.gz \
    https://github.com/ContinuumIO/llvmmath/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/llvmmath

pack_set --module-requirement llvmpy
pack_set --module-requirement numpy

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package llvmath.test
pack_cmd "nosetests --exe llvmmath > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT
