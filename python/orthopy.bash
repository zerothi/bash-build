v=0.5.3
add_package \
    --archive orthopy-$v.tar.gz \
    https://github.com/nschloe/orthopy/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' numpy scipy sympy)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "$(get_parent_exec) setup.py build"

pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package orthopy.test
pack_cmd "pytest --pyargs orthopy > $TEST_OUT 2>&1 ; echo 'Success'"
pack_set_mv_test $TEST_OUT