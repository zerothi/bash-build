v=2.3.3
add_package \
    http://sourceforge.net/projects/pygsl/files/pygsl/pygsl-$v/pygsl-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject $(get_hostname)

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/pygsl

# Add requirments when creating the module
pack_set --module-requirement numpy \
    --module-requirement gsl

# Install commands that it should run
pack_cmd "$_pip_cmd . --config-settings='--gsl-prefix=$(pack_get --prefix gsl)' --prefix=$(pack_get -prefix)"

add_test_package pygsl.test
pack_cmd "nosetests --exe pygsl > $TEST_OUT 2>&1 || echo forced"
pack_store $TEST_OUT
