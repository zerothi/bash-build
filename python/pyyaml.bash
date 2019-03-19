v=3.13
add_package \
    --package pyyaml --version $v \
    http://pyyaml.org/download/pyyaml/PyYAML-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/yaml

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"

return
add_test_package pyyaml.test
pack_cmd "nosetests --exe pyyaml > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
