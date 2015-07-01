v=0.2.2
add_package https://pypi.python.org/packages/source/m/monty/monty-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/monty-$v-py${pV}.egg

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"

return
add_test_package
pack_set --command "nosetests --exe monty > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

