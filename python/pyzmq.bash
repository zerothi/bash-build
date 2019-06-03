# apt-get libzmq-dev
v=18.0.1
add_package --archive pyzmq-$v.tar.gz \
    https://github.com/zeromq/pyzmq/archive/v$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV.egg-info

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
