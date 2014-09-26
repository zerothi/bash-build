# Install
add_package http://ab-initio.mit.edu/meep/meep-1.2.1.tar.gz

pack_set --host-reject ntch --host-reject zeroth \
    $(list --prefix "--host-reject " surt muspel slid a0 b0 c0 d0 n0 p0 q0 g0)

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/meep-mpi

pack_set --module-opt "--lua-family meep"

pack_set --module-requirement openmpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement fftw-2 \
    --module-requirement libctl

# Check for Intel MKL or not
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'"
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'"

elif $(is_c gnu) ; then

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="--with-blas='$(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas'"
	tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath atlas) -llapack'"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp="--with-blas='$(list --LDFLAGS --Wlrpath openblas) -lopenblas'"
	tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath openblas) -llapack'"
    else
	pack_set --module-requirement blas
	tmp="--with-blas='$(list --LDFLAGS --Wlrpath blas) -lblas'"
	tmp="$tmp --with-lapack='$(list --LDFLAGS --Wlrpath blas) -llapack'"
    fi

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
pack_set --module-requirement harminv
tmp="$tmp --with-libctl=$(pack_get --prefix libctl)/share/libctl"

# Install commands that it should run
pack_set --command "autoconf configure.ac > configure"
pack_set --command "./configure" \
    --command-flag "CC='$MPICC' CXX='$MPICXX'" \
    --command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --mod-req))'" \
    --command-flag "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --mod-req))'" \
    --command-flag "--with-mpi" \
    --command-flag "--prefix=$(pack_get --prefix) $tmp" 

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias) 
