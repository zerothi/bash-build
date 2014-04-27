v=0.13.1
add_package https://pypi.python.org/packages/source/p/pandas/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' cython numpy numexpr scipy pytables matplotlib pytz)
if $(is_host ntch) ; then
    echo "" > /dev/null
else
    pack_set --module-requirement bottleneck
fi

pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/python$pV/site-packages"

pack_set --command "$(get_parent_exec) setup.py build"

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe pandas > tmp.test 2>&1 ; echo 'Succes'"
pack_set --command "mv tmp.test $(pack_get --install-query)"
