v=0.15.0
add_package \
    -archive quadpy-$v.tar.gz \
    https://github.com/nschloe/quadpy/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/quadpy

pack_set $(list -prefix ' -module-requirement ' numpy scipy sympy orthopy)

pack_cmd "pip install $pip_install_opts --prefix=$(pack_get -prefix) ."

add_test_package quadpy.test
pack_cmd "pytest --pyargs quadpy > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
