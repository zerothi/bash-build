add_package https://launchpad.net/python-fastimport/trunk/0.9.2/+download/fastimport-0.9.2.tar.gz

pack_set --directory python-$(pack_get --directory)

# We install it into the python
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/fastimport

# Add requirments when creating the module
pack_set --module-requirement $(get_parent)

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix $(get_parent))" \
