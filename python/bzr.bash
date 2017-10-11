# We only accept bzr installation on python 2.x
v=2.7.0
add_package https://launchpad.net/bzr/${v:0:3}/$v/+download/bzr-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/bzr

# Add requirments when creating the module
pack_set --module-requirement $(get_parent) \
    --module-requirement cython

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)" \
