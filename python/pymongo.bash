v=2.7.1
add_package --package pymongo \
    --archive mongo-python-driver-$v.tar.gz \
    https://github.com/mongodb/mongo-python-driver/archive/$v.tar.gz

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV.egg

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"
