v=4.8
add_package --archive pexpect-$v.tar.gz \
    https://github.com/pexpect/pexpect/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --alias)

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
