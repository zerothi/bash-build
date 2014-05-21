# old_v 
for v in 1.4.2 2.4 ; do
    [ "x${pV:0:1}" == "x3" ] && [ "x$v" == "x1.4.2" ] && continue
    fv=$v
    if [ $(vrs_cmp $v 2.3.1 ) -ge 0 ]; then
	fv=v$v
    fi
    add_package --archive numexpr-$v.tar.gz \
	https://github.com/pydata/numexpr/archive/$fv.tar.gz
    
    pack_set -s $IS_MODULE -s $PRELOAD_MODULE

    # This devious thing will never install the same place!!!!!
    pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages
    
    # Add requirments when creating the module
    pack_set --module-requirement numpy \
	--module-requirement cython
    
    # Install commands that it should run
    pack_set --command "mkdir -p" \
	--command-flag "$(pack_get --install-prefix)/lib/python$pV/site-packages"
    pack_set --command "$(get_parent_exec) setup.py build $pNumpyInstall"

    pack_set --command "$(get_parent_exec) setup.py install" \
	--command-flag "--prefix=$(pack_get --install-prefix)"

    add_test_package
    pack_set --command "nosetests --exe numexpr > tmp.test 2>&1 ; echo 'Succes'"
    pack_set --command "mv tmp.test $(pack_get --install-query)"
    
done
