v=0.20.2
add_package --archive pandas-$v.tar.gz \
    https://github.com/pandas-dev/pandas/archive/v$v.tar.gz

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

add_test_package
pack_cmd "nosetests --exe pandas > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
