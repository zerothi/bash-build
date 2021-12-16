v=0.9.3
add_package \
    -archive orthopy-$v.tar.gz \
    https://github.com/nschloe/orthopy/archive/refs/tags/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/orthopy

pack_set $(list -prefix ' -module-requirement ' numpy scipy sympy)

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package orthopy.test
pack_cmd "pytest --pyargs orthopy > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
