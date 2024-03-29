v=3.12.0
add_package https://gitlab.com/slepc/slepc4py/-/archive/$v/slepc4py-$v.tar.bz2

pack_set -s $IS_MODULE

pack_set --module-requirement petsc4py \
    --module-requirement slepc-d

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package slepc4py.test
pack_cmd "nosetests --exe slepc4py > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
