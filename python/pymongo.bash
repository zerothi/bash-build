v=3.12.1
add_package --package pymongo \
    --archive mongo-python-driver-$v.tar.gz \
    https://github.com/mongodb/mongo-python-driver/archive/$v.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/pymongo

# Install commands that it should run
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
