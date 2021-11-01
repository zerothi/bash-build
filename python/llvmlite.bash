# As LLVM is built with gnu-compiler, we should enforce this
# here as well (this only works with 3.6.0)
v=0.37.0
add_package -archive llvmlite-$v.tar.gz \
	    https://github.com/numba/llvmlite/archive/v$v.tar.gz

if [[ "x${pV:0:1}" != "x3" ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/llvmlite

pack_set -build-mod-req build-tools
pack_set -mod-req llvm[9]
pack_set -module-requirement $(get_parent)

pack_cmd "sed -i -e \"s:'7.0:'7:\" ffi/build.py"

pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"


add_test_package llvmlite.test
pack_cmd "$(get_parent_exec) -m llvmlite.tests > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
