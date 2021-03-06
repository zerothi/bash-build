add_package http://pypi.python.org/packages/source/n/nose/nose-1.3.6.tar.gz

pack_set --install-query $(pack_get --prefix $(get_parent))/bin/nosetests

# Add requirments when creating the module
pack_set --module-requirement $(get_parent)

# Install commands that it should run
pack_cmd "sed -i -e \"s/\('nose.sphinx'\)/\1,'nose.tools'/\" setup.py"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install"

