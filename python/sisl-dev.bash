add_package --package sisl-dev --version 0 \
	    https://github.com/zerothi/sisl.git

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query always-install-this-module

pack_set $(list --prefix ' --module-requirement ' scipy netcdf4py)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"

add_test_package sisl-dev.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs sisl > $TEST_OUT 2>&1 ; echo forced"
pack_set_mv_test $TEST_OUT
