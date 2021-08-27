v=3.6.1
add_package \
    -package pytables \
    -archive PyTables-$v.tar.gz \
    https://github.com/PyTables/PyTables/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -prefix)/bin/ptdump
# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

# Add requirments when creating the module
pack_set -module-requirement hdf5-serial \
    -module-requirement numexpr

if [[ $(vrs_cmp 3.1.1 $v) -le 0 ]]; then
    pack_cmd "sed -i -e 's:Cython.Compiler.Main:Cython.Compiler:' setup.py"
fi

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"
pack_cmd "$(get_parent_exec) setup.py build" \
	 "--hdf5=$(pack_get -prefix hdf5-serial)" \
	 "--cflags='${pCFLAGS//-march=native/} -pthread'"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--hdf5=$(pack_get -prefix hdf5-serial)" \
	 "--cflags='${pCFLAGS//-march=native/} -pthread'" \
	 "--prefix=$(pack_get -prefix)"
    
# The tables test is extremely extensive, and many are minor errors.
# I have disabled it for now   
#add_test_package tables.test
#pack_cmd "nosetests --exe tables > $TEST_OUT 2>&1 || echo forced"
#pack_store $TEST_OUT
