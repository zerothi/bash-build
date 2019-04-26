v=3.6
add_package -archive pymc3-$v.tar.gz \
	    https://github.com/pymc-devs/pymc3/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numpy scipy pandas patsy h5py theano)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

add_test_package pymc3.test
pack_cmd "pytest --pyargs pymc3 > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
