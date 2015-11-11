for v in 3.1.0 ; do
    
add_package http://qutip.org/downloads/$v/qutip-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$p_name

# Add requirments when creating the module
pack_set --module-requirement scipy \
    --module-requirement cython \
    --module-requirement matplotlib

# clean-up until it has been fixed upstream
pack_cmd "sed -i -e '/extra_/d' qutip/fortran/setup.py"

pack_cmd "unset LDFLAGS"

# Install commands that it should run
pack_cmd "$(get_parent_exec) setup.py build --with-f90mc"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"
    
done
