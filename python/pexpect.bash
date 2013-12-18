add_package --archive pexpect-3.0.tar.gz \
    https://github.com/pexpect/pexpect/archive/3.0.tar.gz

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"
