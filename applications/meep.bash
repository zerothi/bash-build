# Install
add_package http://ab-initio.mit.edu/meep/meep-1.2.1.tar.gz

pack_set --host-reject ntch --host-reject zeroth \
    $(list --prefix "--host-reject " surt muspel slid a0 b0 c0 d0 n0 p0 q0 g0 n-)

pack_set --install-query $(pack_get --prefix)/bin/meep-mpi

pack_set --module-opt "--lua-family meep"

pack_set --module-requirement mpi \
    --module-requirement zlib \
    --module-requirement hdf5 \
    --module-requirement fftw-3 \
    --module-requirement libctl

# Check for Intel MKL or not
tmp=
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'"
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'"

elif $(is_c gnu) ; then

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LDFLAGS --Wlrpath $la)"
	    tmp="$tmp --with-lapack='$tmp_ld -llapack'"
	    if [ "x$la" == "xatlas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lf77blas -lcblas -latlas'"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lopenblas'"
	    elif [ "x$la" == "xblas" ]; then
		tmp="$tmp --with-blas='$tmp_ld -lblas'"
	    fi
	    break
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
pack_set --module-requirement harminv
tmp="$tmp --with-libctl=$(pack_get --prefix libctl)/share/libctl"

pack_set --command "module load build-tools"

# Install commands that it should run
pack_set --command "autoconf configure.ac > configure"
pack_set --command "./configure" \
    --command-flag "CC='$MPICC' CXX='$MPICXX'" \
    --command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --mod-req-path))'" \
    --command-flag "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --mod-req-path))'" \
    --command-flag "--with-mpi" \
    --command-flag "--prefix=$(pack_get --prefix) $tmp" 

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_set --command "module unload build-tools"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias) 
