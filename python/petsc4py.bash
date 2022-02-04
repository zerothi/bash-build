add_package -package petsc4py \
	    -directory $(pack_get -directory petsc-d) \
	    $(pack_get -archive petsc-d)

pack_set -s $IS_MODULE

pack_set -module-requirement petsc-d \
	 -module-requirement mpi4py -module-requirement numpy \
	 -module-requirement cython

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/$(pack_get -alias)/__init__.py

pack_cmd "cd src/binding/petsc4py"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package petsc4py.test
pack_cmd "nosetests --exe petsc4py > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT


