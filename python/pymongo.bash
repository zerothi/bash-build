v=3.10.1
add_package --package pymongo \
    --archive mongo-python-driver-$v.tar.gz \
    https://github.com/mongodb/mongo-python-driver/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/pymongo-$v-py$pV-linux-x86_64.egg

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix $(get_parent))"
