v=0.12.1
add_package --archive llvmpy-$v.tar.gz \
    https://github.com/llvmpy/llvmpy/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/llvmpy

pack_set --module-requirement $(get_parent)
pack_set --module-requirement llvm[3.3]

pack_set --command "LLVM_CONFIG_PATH=$(pack_get --install-prefix llvm[3.3])/bin/llvm-config $(get_parent_exec)" \
    --command-flag "setup.py install --prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe llvm > tmp.test 2>&1"
pack_set --command "mv tmp.test $(pack_get --install-query)"
