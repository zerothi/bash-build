v=0.5.1
add_package -archive patsy-$v.tar.gz \
    https://github.com/pydata/patsy/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numpy scipy)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

add_test_package patsy.test
pack_cmd "nosetests --exe patsy > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
