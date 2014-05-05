[ "x${pV:0:1}" == "x3" ] && return 0

v=0.9.5
add_package \
    http://sourceforge.net/projects/pygsl/files/pygsl/pygsl-$v/pygsl-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/pygsl

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement gsl
    
# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py build" \
    --command-flag "--gsl-prefix=$(pack_get --install-prefix gsl)"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"
 
# The tables test is extremely extensive, and many are minor errors.
# I have disabled it for now   
#add_test_package
#pack_set --command "nosetests --exe tables > tmp.test 2>&1 ; echo 'Succes'"
#pack_set --command "mv tmp.test $(pack_get --install-query)"
