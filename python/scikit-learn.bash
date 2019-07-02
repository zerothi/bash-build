[ "x${pV:0:1}" == "x2" ] && return 0
v=0.21.2
add_package -archive scikit-learn-$v.tar.gz \
    https://github.com/scikit-learn/scikit-learn/archive/$v.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/sklearn/__init__.py

# Add requirments when creating the module
pack_set -module-requirement numpy \
	 -module-requirement scipy \
	 -module-requirement cython

pack_cmd "unset LDFLAGS"
pack_cmd "OMP_NUM_THREADS=$NPROCS $(get_parent_exec) setup.py build ${pNumpyInstallC}"
pack_cmd "OMP_NUM_THREADS=$NPROCS $(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"

add_test_package sklearn.test
pack_set -module-requirement pandas
pack_cmd "pytest --exe sklearn > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
