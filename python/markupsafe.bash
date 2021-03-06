v=1.1.1
add_package \
    --package markupsafe \
    https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/MarkupSafe-$v-py${pV}-linux-x86_64.egg

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
