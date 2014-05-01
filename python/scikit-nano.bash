v=0.2.24
add_package \
    --archive scikit-nano-$v.tar.gz \
    https://github.com/androomerrill/scikit-nano/archive/v$v.tar.gz

pack_set --module-requirement pint \
    --module-requirement numpy

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"
