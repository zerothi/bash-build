v=2.20.0
add_package \
    --archive dask-$v.tar.gz \
    https://github.com/dask/dask/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' numpy pandas)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"


add_test_package dask.test
pack_cmd "pytest --pyargs dask > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
