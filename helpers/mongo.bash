v=2.7.3
add_package --build generic \
    --package mongo \
    --archive mongo-r$v.tar.gz \
    https://github.com/mongodb/mongo/archive/r$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/mongo

pack_set --command "module load $(pack_get --module-load scons)"

# Install commands that it should run
pack_set --command "scons all"
pack_set --command "scons" \
    --command-flag "--prefix=$(pack_get --install-prefix)" \
    --command-flag "install"

pack_set --command "module unload $(pack_get --module-load scons)"

pack_install
