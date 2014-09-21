v=3.3
add_package --archive pexpect-$v.tar.gz \
    https://github.com/pexpect/pexpect/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))"
