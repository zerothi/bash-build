[ "x${pV:0:1}" == "x3" ] && return 0

v=0.14.1
add_package \
    https://pypi.python.org/packages/source/s/scikit-learn/scikit-learn-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/sklearn/__init__.py

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement scipy
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe sklearn > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
