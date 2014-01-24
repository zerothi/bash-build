v=0.12.1
add_package --archive llvmpy-$v.tar.gz \
    https://github.com/llvmpy/llvmpy/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages

pack_set --module-requirement python
pack_set --module-requirement llvm[3.2]

pack_set --command "LLVM_CONFIG_PATH=$(pack_get --install-prefix llvm[3.2])/bin/llvm-config $(get_parent_exec)" \
    --command-flag "setup.py install --prefix=$(pack_get --install-prefix)"


add_package --package llvmpy-test fake
pack_set --module-requirement llvmpy
pack_set --command "$(get_parent_exec) -c 'import llvm; llvm.test()'"