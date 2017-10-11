# As LLVM is built with gnu-compiler, we should enforce this
# here as well (this only works with 3.6.0)
v=0.7.0
add_package --build generic --archive llvmlite-$v.tar.gz \
    https://github.com/numba/llvmlite/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/llvm-lite

pack_set --module-requirement $(get_parent)
pack_set --module-requirement llvm

pack_cmd "$(get_parent_exec)" \
    "setup.py install --prefix=$(pack_get --prefix)"

add_test_package llvm-lite.test
pack_cmd "nosetests --exe llvm-lite > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT
