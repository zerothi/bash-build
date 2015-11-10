add_package https://bitbucket.org/mpi4py/mpi4py/downloads/mpi4py-2.0.0.tar.gz

pack_set -s $IS_MODULE

pack_set --module-requirement mpi

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$(pack_get --alias)/__init__.py

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

tmp="-v -f --no-numpy"
for i in 1 2 ; do
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp 2>&1 >> tmp$i.test"
    pack_set_mv_test tmp$i.test
    pack_cmd "mpirun -np $i $(get_parent_exec) test/runtests.py $tmp --thread-level funneled 2>&1 >> tmpthread$i.test"
    pack_set_mv_test tmpthread$i.test
done
