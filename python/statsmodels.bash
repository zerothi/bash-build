v=0.9.0
add_package -archive statsmodels-$v.tar.gz \
    https://github.com/statsmodels/statsmodels/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' cython numpy scipy pandas patsy)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

add_test_package statsmodels.test
pack_cmd "nosetests --exe statsmodels > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
