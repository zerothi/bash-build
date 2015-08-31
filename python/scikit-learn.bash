[ "x${pV:0:1}" == "x3" ] && return 0
v=0.15.2
add_package --archive scikit-learn-$v.tar.gz \
    https://github.com/scikit-learn/scikit-learn/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/sklearn/__init__.py

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement scipy

pack_set --host-reject $(get_hostname)

if $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package
pack_cmd "nosetests --exe sklearn > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
