v=0.12.7
add_package --archive llvmpy-$v.tar.gz \
    https://github.com/llvmpy/llvmpy/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/llvmpy

pack_set --module-requirement $(get_parent)
pack_set --module-requirement llvm

pack_cmd "LLVM_CONFIG_PATH=$(pack_get --prefix llvm)/bin/llvm-config $(get_parent_exec)" \
    "setup.py install --prefix=$(pack_get --prefix)"

add_test_package
pack_cmd "nosetests --exe llvm > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
