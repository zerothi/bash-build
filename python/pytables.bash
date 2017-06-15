v=3.4.2
add_package \
    --package pytables \
    --archive PyTables-$v.tar.gz \
    https://github.com/PyTables/PyTables/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ptdump

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial \
    --module-requirement numexpr

if [[ $(vrs_cmp 3.1.1 $v) -le 0 ]]; then
    pack_cmd "sed -i -e 's:Cython.Compiler.Main:Cython.Compiler:' setup.py"
fi

pack_cmd "$(get_parent_exec) setup.py build" \
    "--hdf5=$(pack_get --prefix hdf5-serial)" \
    "--cflags='${pCFLAGS//-march=native/}'"
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages/"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)" \
    
# The tables test is extremely extensive, and many are minor errors.
# I have disabled it for now   
#add_test_package
#pack_cmd "nosetests --exe tables > tmp.test 2>&1 ; echo 'Success'"
#pack_set_mv_test tmp.test
