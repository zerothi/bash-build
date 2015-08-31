[ "x${pV:0:1}" == "x3" ] && return 0

# We only accept bzr installation on python 2.x
add_package https://launchpad.net/bzr/2.6/2.6.0/+download/bzr-2.6.0.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/bzr

# Add requirments when creating the module
pack_set --module-requirement $(get_parent) \
    --module-requirement cython

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)" \
