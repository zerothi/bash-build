tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://pypi.python.org/packages/source/n/nose/nose-1.2.1.tar.gz

#pack_set -s $IS_MODULE

#pack_set --install-prefix \
#    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

#pack_set --module-name \
#    $(pack_get --package $idx)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix $(get_parent))/bin/nosetests

# Add requirments when creating the module
pack_set --module-requirement $(get_parent)
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" # \
#    --command-flag "--prefix=$(pack_get --install-prefix)" \
    
pack_install