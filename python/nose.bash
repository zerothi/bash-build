add_package http://pypi.python.org/packages/source/n/nose/nose-1.3.0.tar.gz

pack_set --install-query $(pack_get --install-prefix $(get_parent))/bin/nosetests

# Add requirments when creating the module
pack_set --module-requirement $(get_parent)

# Install commands that it should run
pack_set --command "sed -i -e \"s/\('nose.sphinx'\)/\1,'nose.tools'/\" setup.py"
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install"

