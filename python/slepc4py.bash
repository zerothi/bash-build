add_package https://bitbucket.org/slepc/slepc4py/downloads/slepc4py-3.10.0.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement petsc4py \
    --module-requirement slepc

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package slepc4py.test
pack_cmd "nosetests --exe slepc4py > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT
