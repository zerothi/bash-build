tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://downloads.sourceforge.net/project/scipy/scipy/0.11.0/scipy-0.11.0.tar.gz

pack_set -s $IS_MODULE

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/python$pV/site-packages/$(pack_get --alias)

pack_set $(list --pack-module-reqs numpy)

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 

elif [ "${tmp:0:3}" == "gnu" ]; then
    # The atlas requirement should come from numpy
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py build" \
	--command-flag "--compiler=unix" \
	--command-flag "--fcompiler=gnu95" 

else
    doerr $(pack_get --package) "Could not recognize the compiler: $(get_c)"
fi

# Install commands that it should run
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

module load $(pack_get --module-name pcre) $(pack_get --module-name swig)
pack_install
module unload $(pack_get --module-name pcre) $(pack_get --module-name swig)
