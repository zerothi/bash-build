v=0.3.0
add_package --archive sids-$v.tar.gz \
    https://github.com/zerothi/sids/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' scipy netcdf4py)

pack_cmd "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"


add_test_package
pack_cmd "unset LDFLAGS"
pack_cmd "nosetests --exe sids > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
