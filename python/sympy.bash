v=0.7.5
add_package --directory sympy-$v \
    --package sympy --version $v \
    https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' numpy cython scipy matplotlib)

if $(is_c intel) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem"

elif $(is_c gnu) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix"

else
    doerr $(pack_get --package) "Could not recognize the compiler: $(get_c)"
fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

add_test_package
pack_set --command "nosetests --exe sympy > tmp.test 2>&1 ; echo 'Succes'"
pack_set --command "mv tmp.test $(pack_get --install-query)"
