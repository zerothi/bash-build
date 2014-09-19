v=0.85
add_package --archive fireworks-$v.tar.gz \
    https://github.com/materialsproject/fireworks/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement mongo

pack_set --install-query $(pack_get --install-prefix)/bin/mlaunch

pack_set --command "mkdir -p $(pack_get --library-path)/python$pV/site-packages/"

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe fireworks > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test

