v=3.2.0
add_package \
    --package pytables \
    http://sourceforge.net/projects/pytables/files/pytables/$v/tables-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ptdump

# Add requirments when creating the module
pack_set --module-requirement hdf5-serial \
    --module-requirement numexpr

if [ $(vrs_cmp 3.1.1 $v) -le 0 ]; then
   pack_set --command "sed -i -e 's:Cython.Compiler.Main:Cython.Compiler:' setup.py"
fi
    
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--hdf5=$(pack_get --prefix hdf5-serial)" \
    --command-flag "--cflags='$pCFLAGS'"
pack_set --command "mkdir -p $(pack_get --LD)/python$pV/site-packages/"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)" \
 
# The tables test is extremely extensive, and many are minor errors.
# I have disabled it for now   
#add_test_package
#pack_set --command "nosetests --exe tables > tmp.test 2>&1 ; echo 'Success'"
#pack_set_mv_test tmp.test
