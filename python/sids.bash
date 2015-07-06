v=0.1.3
add_package --archive sids-$v.tar.gz \
    https://github.com/zerothi/sids/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' scipy netcdf4py)

pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build ${pNumpyInstall}"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"


add_test_package
pack_set --command "unset LDFLAGS"
pack_set --command "nosetests --exe sids > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
