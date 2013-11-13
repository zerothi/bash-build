add_package http://archive.ipython.org/release/1.1.0/ipython-1.1.0.tar.gz

pack_set --install-query $(pack_get --install-prefix $(get_parent))/lib/python$pV/site-packages/IPython

pack_set --command "$(get_parent_exec) setup.py build"

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix $(get_parent))"
