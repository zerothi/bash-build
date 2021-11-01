v=4.1.2
add_package \
    https://pypi.python.org/packages/source/j/jsonschema/jsonschema-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$v-py${pV}.egg

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
