v=2.5.0
add_package -archive imageio-$v.tar.gz \
	    https://github.com/imageio/imageio/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set $(list -prefix ' -module-requirement ' numpy)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstallC"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

add_test_package imageio.test
pack_cmd "pytest --pyargs imageio > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
