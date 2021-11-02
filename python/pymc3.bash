v=3.11.4
add_package -archive pymc3-$v.tar.gz \
	    https://github.com/pymc-devs/pymc3/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pymc3

pack_set $(list -prefix ' -module-requirement ' numpy scipy pandas h5py theano)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package pymc3.test
pack_cmd "pytest --pyargs pymc3 > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
