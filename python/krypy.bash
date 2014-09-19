v=2.1.1
add_package \
    --archive krypy-$v.tar.gz \
    https://github.com/andrenarchy/krypy/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/python$pV/site-packages/krypy

# Add requirments when creating the module
pack_set --module-requirement scipy
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
 
