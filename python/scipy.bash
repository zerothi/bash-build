for v in 0.13.0 ; do 
add_package http://downloads.sourceforge.net/project/scipy/scipy/$v/scipy-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set --module-requirement numpy

if [ $(pack_installed swig) -eq 1 ]; then
    pack_set --command "module load $(pack_get --module-name-requirement pcre swig) $(pack_get --module-name pcre swig)"
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 
    # TODO
    #export LD_RUN_PATH="$MKL_PATH/lib/intel64"

elif $(is_c gnu) ; then
    # The atlas requirement should come from numpy
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix" \
	--command-flag "--fcompiler=gnu95" 

else
    doerr $(pack_get --package) "Could not recognize the compiler: $(get_c)"
fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

if [ $(pack_installed swig) -eq 1 ]; then
    pack_set --command "module unload $(pack_get --module-name swig pcre) $(pack_get --module-name-requirement pcre swig)"
fi

done