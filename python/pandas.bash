v=0.22.0
add_package \
    https://github.com/pandas-dev/pandas/releases/download/v$v/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' cython numpy numexpr scipy pytables matplotlib)
if $(is_host ntch) ; then
    echo "" > /dev/null
else
    pack_set --module-requirement bottleneck
fi

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

#add_test_package pandas.test
#pack_cmd "nosetests --exe pandas > $TEST_OUT 2>&1 ; echo 'Success'"
#pack_set_mv_test $TEST_OUT
