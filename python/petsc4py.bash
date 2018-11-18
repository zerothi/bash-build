add_package https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-3.10.0.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement $(get_parent) \
    --module-requirement petsc-r \
    --module-requirement mpi4py --module-requirement numpy \
    --module-requirement cython

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package petsc4py.test
pack_cmd "nosetests --exe petsc4py > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT


