for v in 0.12.0 ; do 
add_package https://pypi.python.org/packages/source/p/pandas/pandas-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --prefix ' --module-requirement ' numpy numexpr[2] scipy pytables matplotlib bottleneck)

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

done