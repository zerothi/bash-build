v=1.5.3
add_package \
    https://github.com/pandas-dev/pandas/releases/download/v$v/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pandas

pack_set -build-mod-req cython

pack_set $(list -prefix ' -module-requirement ' numpy numexpr)
if [[ $(pack_get -installed bottleneck) -eq 1 ]]; then
    pack_set -mod-req bottleneck
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

#add_test_package pandas.test
#pack_cmd "nosetests --exe pandas > $TEST_OUT 2>&1 || echo forced"
#pack_store $TEST_OUT



v=2.0.0
add_package \
    https://github.com/pandas-dev/pandas/releases/download/v$v/pandas-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pandas

pack_set -build-mod-req cython

pack_set $(list -prefix ' -module-requirement ' numpy numexpr scipy pytables matplotlib)
if [[ $(pack_get -installed numba) -eq 1 ]]; then
    pack_set -mod-req numba
fi
if [[ $(pack_get -installed bottleneck) -eq 1 ]]; then
    pack_set -mod-req bottleneck
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

#add_test_package pandas.test
#pack_cmd "nosetests --exe pandas > $TEST_OUT 2>&1 || echo forced"
#pack_store $TEST_OUT
