v=2.4.0
add_package \
    https://pypi.python.org/packages/source/j/jsonschema/jsonschema-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$v-py${pV}-linux-x86_64.egg

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
