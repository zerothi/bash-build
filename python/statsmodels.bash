v=0.14.0
add_package -archive statsmodels-$v.tar.gz \
    https://github.com/statsmodels/statsmodels/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/statsmodels

pack_set -build-mod-req cython
pack_set $(list -prefix ' -module-requirement ' numpy scipy pandas)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "SETUPTOOLS_SCM_PRETEND_VERSION=$v $_pip_cmd . --prefix=$(pack_get -prefix)"

#add_test_package statsmodels.test
#pack_cmd "nosetests --exe statsmodels > $TEST_OUT 2>&1 || echo forced"
#pack_store $TEST_OUT
