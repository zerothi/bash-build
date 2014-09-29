v=2.7.3
add_package \
    --package jinja2 \
    https://pypi.python.org/packages/source/J/Jinja2/Jinja2-$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/Jinja2-$v-py${pV}.egg

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
