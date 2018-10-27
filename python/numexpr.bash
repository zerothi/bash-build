# old_v 
for v in 2.6.8 ; do
    [ "x${pV:0:1}" == "x3" ] && [ "x$v" == "x1.4.2" ] && continue
    fv=$v
    if [[ $(vrs_cmp $v 2.3.1 ) -ge 0 ]]; then
	fv=v$v
    fi
    add_package --archive numexpr-$v.tar.gz \
	https://github.com/pydata/numexpr/archive/$fv.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --LD)/python$pV/site-packages
    
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement cython
    
    # Install commands that it should run
    pack_cmd "mkdir -p" \
	  "$(pack_get --LD)/python$pV/site-packages"
    pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstall"

    pack_cmd "$(get_parent_exec) setup.py install" \
	  "--prefix=$(pack_get --prefix)"

    add_test_package numexpr.test
    pack_cmd "nosetests --exe numexpr > $TEST_OUT 2>&1 ; echo 'Success'"
    pack_set_mv_test $TEST_OUT
    
done
