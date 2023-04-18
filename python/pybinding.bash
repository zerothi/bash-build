v=0.9.5
add_package --archive pybinding-$v.tar.gz https://github.com/dean0x7d/pybinding/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

if [[ $(vrs_cmp $pV 3.4) -lt 0 ]]; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/pybinding
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --module-opt "--lua-family pybinding"

pack_set -build-mod-req cython \
	-build-mod-req pybind11
pack_set --module-requirement scipy \
	 --module-requirement matplotlib

pack_cmd "echo 'Fake' > changelog.md"

# Fix CMakelists.txt
pack_cmd "sed -i -e 's:add_subdirectory.*:add_subdirectory($(pack_get --prefix pybind11) EXCLUDE_FROM_ALL):' cppmodule/CMakeLists.txt"

pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $_pip_cmd --prefix=$(pack_get -prefix)"

add_test_package pybinding.test
pack_cmd "pytest --pyargs pybinding 2>&1 > $TEST_OUT || echo forced"
pack_store $TEST_OUT
