for v in 4.6.7 5.0.4 ; do
add_package ftp://ftp.gromacs.org/pub/gromacs/gromacs-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family gromacs"

pack_set --host-reject ntch --host-reject zerothi
if $(is_c gnu) ; then
    pack_set $(list -p '--host-reject ' n-62-25 n-62-26)
fi

pack_set --install-query $(pack_get --prefix)/bin/GMXRC

pack_set --module-requirement mpi --module-requirement fftw-3

pack_set --command "module load $(pack_get --module-name cmake)"

tmp="-DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)"
tmp="$tmp -DGMX_GPU=OFF"
if $(is_c intel) ; then
    # hopefully this should be enough
    tmp="$tmp -DGMX_BLAS_USER='-mkl=parallel'"
elif $(is_c gnu) ; then

    # We use a c-linker (which does not add gfortran library
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LD-rp $la)"
	    if [ "x$la" == "xatlas" ]; then
		tmp="$tmp -DGMX_BLAS_USER='$(trim_spaces $tmp_ld) -lf77blas -lcblas -latlas -lgfortran'"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp="$tmp -DGMX_BLAS_USER='$(trim_spaces $tmp_ld) -lopenblas -lgfortran'"
	    elif [ "x$la" == "xblas" ]; then
		tmp="$tmp -DGMX_BLAS_USER='$(trim_spaces $tmp_ld) -lblas -lgfortran'"
	    fi
	    break
	fi
    done

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi

clib="$(list --prefix ':' --loop-cmd 'pack_get --LD' $(pack_get --mod-req))"
clib=${clib// /}
clib=${clib:1}

# configure the build...
pack_set --command "cmake .. $tmp -DCMAKE_PREFIX_PATH='$clib'"

# Make commands (cmake --build removes color)
pack_set --command "cmake --build ."
pack_set --command "cmake --build . --target install"
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
