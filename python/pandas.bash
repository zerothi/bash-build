v=0.16.0
add_package https://pypi.python.org/packages/source/p/pandas/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py
pack_set --host-reject n-

pack_set $(list --prefix ' --module-requirement ' cython numpy numexpr scipy pytables matplotlib)
if $(is_host ntch) ; then
    echo "" > /dev/null
else
    pack_set --module-requirement bottleneck
fi

pack_set --command "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_set --command "$(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe pandas > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
