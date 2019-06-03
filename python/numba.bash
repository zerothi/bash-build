v=0.43.1
add_package -archive numba-$v.tar.gz \
	    https://github.com/numba/numba/archive/$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -module-requirement numpy
pack_set -module-requirement cython
pack_set -module-requirement llvmlite

pack_set -install-query $(pack_get -prefix)/bin/numba

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"


add_test_package numba.test
pack_cmd "$(get_parent_exec) -m numba.runtests --exclude-tags='long_running' > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT

