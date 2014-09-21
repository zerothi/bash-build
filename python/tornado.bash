v=4.0.1
add_package --archive tornado-$v.tar.gz https://github.com/tornadoweb/tornado/archive/v$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV-linux-x86_64.egg

pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"


