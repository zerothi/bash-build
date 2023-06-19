v=2023.3.2
add_package \
    --archive distributed-$v.tar.gz \
    https://github.com/dask/distributed/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --module-requirement dask

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/distributed

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"
_fix_versioneer $v

pack_cmd "SETUPTOOLS_SCM_PRETEND_VERSION=$v $_pip_cmd . --prefix=$(pack_get --prefix)"


add_test_package distributed.test
pack_cmd "pytest --pyargs distributed > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
