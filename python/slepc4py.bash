v=3.18.3
add_package https://files.pythonhosted.org/packages/source/s/slepc4py/slepc4py-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement petsc4py \
    --module-requirement slepc-d

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package slepc4py.test
pack_cmd "nosetests --exe slepc4py > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
