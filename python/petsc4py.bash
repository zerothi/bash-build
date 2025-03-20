for prec in d z ; do

add_package -package petsc4py-$prec \
  -directory $(pack_get -directory petsc-$prec) \
  $(pack_get -archive petsc-$prec)

pack_set -s $IS_MODULE

pack_set -build-mod-req cython
pack_set -module-requirement petsc-$prec \
  -module-requirement mpi4py -module-requirement numpy

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/petsc4py/__init__.py

pack_cmd "cd src/binding/petsc4py"
pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

add_test_package petsc4py.test
pack_cmd "nosetests --exe petsc4py > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT

done
