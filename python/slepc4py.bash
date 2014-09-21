add_package https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-3.5.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement petsc4py \
    --module-requirement slepc

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe slepc4py > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test
