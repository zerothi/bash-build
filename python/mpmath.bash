v=1.1.0
add_package --archive mpmath-$v.tar.gz \
    https://github.com/fredrik-johansson/mpmath/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/mpmath

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get --prefix)"

add_test_package mpmath.test
pack_cmd "nosetests --exe mpmath > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
