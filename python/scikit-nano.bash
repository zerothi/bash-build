v=0.3.21
add_package \
    --archive scikit-nano-$v.tar.gz \
    https://github.com/scikit-nano/scikit-nano/archive/v$v.tar.gz

pack_set --module-requirement pint \
    --module-requirement scipy

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --alias)

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
