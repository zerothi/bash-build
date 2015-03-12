# As LLVM is built with gnu-compiler, we should enforce this
# here as well (this only works with 3.5.1)
v=0.3.0
add_package --build generic --archive llvmlite-$v.tar.gz \
    https://github.com/numba/llvmlite/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/llvm-lite

pack_set --module-requirement $(get_parent)
pack_set --module-requirement cffi
pack_set --module-requirement llvm[3.5]
pack_set --host-reject $(get_hostname)

pack_set --command "$(get_parent_exec)" \
    --command-flag "setup.py install --prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe llvm-lite > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
