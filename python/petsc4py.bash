add_package https://bitbucket.org/petsc/petsc4py/downloads/petsc4py-3.5.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement $(get_parent) \
    --module-requirement petsc \
    --module-requirement mpi4py --module-requirement numpy \
    --module-requirement cython

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe petsc4py > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test


