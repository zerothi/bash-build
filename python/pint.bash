v=0.4.2
add_package \
    --package pint \
    --archive pint-$v.zip \
    --directory Pint-$v \
    https://pypi.python.org/packages/source/P/Pint/Pint-$v.zip

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"
