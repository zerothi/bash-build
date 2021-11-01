v=3.1.1
add_package https://github.com/mpi4py/mpi4py/releases/download/$v/mpi4py-$v.tar.gz

pack_set -s $IS_MODULE

pack_set -module-requirement mpi
pack_set -module-requirement numpy

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/$(pack_get -alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get -prefix)"

if [ 1 -eq 0 ]; then
tmp="-v -f --exclude test_rma --exclude test_spawn"
for i in 1 2 ; do
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp --no-numpy 2>&1 >> mpi4py_$i.test || echo forced"
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp 2>&1 >> mpi4py_$i.test || echo forced"
    pack_store mpi4py_$i.test
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp --no-numpy --thread-level funneled 2>&1 >> mpi4py_thread_$i.test || echo forced"
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp --thread-level funneled 2>&1 >> mpi4py_thread_$i.test || echo forced"
    pack_store mpi4py_thread_$i.test
done
fi
