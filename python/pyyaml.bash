v=3.11
add_package \
    --package pyyaml --version $v \
    http://pyyaml.org/download/pyyaml/PyYAML-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/yaml

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"

return
add_test_package
pack_set --command "nosetests --exe pyyaml > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
