v=1.25.0
add_package \
    --archive distributed-$v.tar.gz \
    https://github.com/dask/distributed/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement dask

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/distributed*

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"


add_test_package distributed.test
pack_cmd "pytest --pyargs distributed > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
