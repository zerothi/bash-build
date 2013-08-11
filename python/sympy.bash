for v in 0.7.3 ; do 
add_package https://github.com/sympy/sympy/releases/download/sympy-$v/sympy-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' numpy cython scipy matplotlib)

if $(is_c intel) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 

elif $(is_c gnu) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix" \
	--command-flag "--fcompiler=gnu95" 

else
    doerr $(pack_get --package) "Could not recognize the compiler: $(get_c)"
fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done