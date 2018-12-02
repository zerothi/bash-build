v=0.12.6
add_package \
    --archive quadpy-$v.tar.gz \
    https://github.com/nschloe/quadpy/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' numpy scipy sympy orthopy)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package quadpy.test
pack_cmd "pytest --pyargs quadpy > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT
