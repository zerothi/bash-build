v=0.8.5
add_package --archive sisl-$v.tar.gz \
    https://github.com/zerothi/sisl/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' scipy netcdf4py)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"


return 0
add_test_package sisl.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs sisl > $TEST_OUT 2>&1"
pack_set_mv_test $TEST_OUT
