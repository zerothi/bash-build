for v in 4.6.2 ; do
    
add_package -archive qutip-$v.tar.gz https://github.com/qutip/qutip/archive/v$v.tar.gz
pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/$p_name

# Add requirments when creating the module
pack_set --module-requirement scipy \
    --module-requirement cython \
    --module-requirement matplotlib

# clean-up until it has been fixed upstream
#pack_cmd "sed -i -e '/extra_/d' qutip/fortran/setup.py"

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

pack_cmd "unset LDFLAGS"

# Install commands that it should run
pack_cmd "$_pip_cmd . --install-option=--with-openmp --prefix=$(pack_get -prefix)"
    
done
