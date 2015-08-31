[ "x${pV:0:1}" == "x3" ] && return 0

# We only accept bzr installation on python 2.x
add_package https://launchpad.net/bzr-fastimport/trunk/0.13.0/+download/bzr-fastimport-0.13.0.tar.gz

# We install it into the bzr package
pack_set --install-query $(pack_get --LD bzr)/python$pV/site-packages/bzrlib/plugins/fastimport

# Add requirments when creating the module
pack_set --module-requirement $(get_parent) \
    --module-requirement bzr


# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix bzr)" \
