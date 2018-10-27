v=2.1.7
add_package \
    --archive krypy-$v.tar.gz \
    https://github.com/andrenarchy/krypy/archive/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/krypy

# Add requirments when creating the module
pack_set --module-requirement scipy
    
# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
      "--prefix=$(pack_get --prefix)"
 
