v=6.1.0
add_package --archive tornado-$v.tar.gz https://github.com/tornadoweb/tornado/archive/v$v.tar.gz

pack_set --module-requirement $(get_parent)
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV-linux-x86_64.egg

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"


