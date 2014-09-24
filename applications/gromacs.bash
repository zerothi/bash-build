for v in 4.6.7 5.0.1 ; do
add_package ftp://ftp.gromacs.org/pub/gromacs/gromacs-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family gromacs"

pack_set --host-reject ntch --host-reject zerothi

pack_set --install-query $(pack_get --prefix)/bin/GMXRC

pack_set --module-requirement openmpi --module-requirement fftw-3

pack_set --command "module load $(pack_get --module-name cmake)"

tmp="-DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)"
if $(is_c intel) ; then
    # hopefully this should be enough
    tmp="$tmp -DGMX_BLAS_USER='-mkl=parallel'"
elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp="$tmp -DGMX_BLAS_USER='-lf77blas -lcblas -latlas -lgfortran'" # to be able to link c to fortran
    else
	pack_set --module-requirement blas
	tmp="$tmp -DGMX_BLAS_USER='-lblas -lgfortran'"
    fi

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi

clib="$(list --prefix ':' --loop-cmd 'pack_get --LD' $(pack_get --mod-req))"
clib=${clib// /}
clib=${clib:1}

# configure the build...
pack_set --command "cmake .. $tmp -DCMAKE_PREFIX_PATH='$clib'"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
pack_set --command "module unload $(pack_get --module-name cmake)"

# Add GROMACS envs
pack_set --module-opt "--set-ENV GMXBIN=$(pack_get --prefix)/bin"
pack_set --module-opt "--set-ENV GMXLDLIB=$(pack_get --LD)"
pack_set --module-opt "--set-ENV GMXMAN=$(pack_get --prefix)/man"
pack_set --module-opt "--set-ENV GMXDATA=$(pack_get --prefix)/share/gromacs"

# Add auto source scripts (if users wishes to use these)
pack_set --module-opt "--set-ENV GMXRC_BASH=$(pack_get --prefix)/bin/GMXRC.bash"
pack_set --module-opt "--set-ENV GMXRC_CSH=$(pack_get --prefix)/bin/GMXRC.csh"
pack_set --module-opt "--set-ENV GMXRC_ZSH=$(pack_get --prefix)/bin/GMXRC.zsh"

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)

done
