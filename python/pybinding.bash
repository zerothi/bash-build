v=0.9.4
add_package --archive pybinding-$v.tar.gz https://github.com/dean0x7d/pybinding/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

if [[ $(vrs_cmp $pV 3.4) -lt 0 ]]; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --module-opt "--lua-family pybinding"

pack_set --module-requirement cython \
	 --module-requirement scipy \
	 --module-requirement matplotlib \
	 --module-requirement pybind11

pack_cmd "module load cmake"

pack_cmd "echo 'Fake' > changelog.md"

# Fix CMakelists.txt
pack_cmd "sed -i -e 's:add_subdirectory.*:add_subdirectory($(pack_get --prefix pybind11) EXCLUDE_FROM_ALL):' cppmodule/CMakeLists.txt"

pack_cmd "CFLAGS='$pCFLAGS $tmp_flags' $(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"

pack_cmd "module unload cmake"

add_test_package pybinding.test
pack_cmd "pytest --pyargs pybinding 2>&1 > $TEST_OUT ; echo 'Success'"
pack_set_mv_test $TEST_OUT
