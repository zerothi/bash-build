# http://qe-forge.org/gf/download/frsrelease/116/211/espresso-5.0.tar.gz
# This has problems with the xspectra package which is erroneous in the tar
# Hence we cannot install it, yet.
# http://qe-forge.org/gf/download/frsrelease/116/403/espresso-5.0.2.tar.gz
for v in \
    http://qe-forge.org/gf/download/frsrelease/116/347/espresso-5.0.1.tar.gz \
    ; do

    add_package $v
    
    pack_set -s $IS_MODULE

    pack_set --host-reject "ntch"

    pack_set --install-query $(pack_get --install-prefix)/bin/pw.x

    pack_set --module-opt "--lua-family espresso"

    pack_set --module-requirement openmpi 
    pack_set --module-requirement fftw-3

# Check for Intel MKL or not
    tmp_lib="FFT_LIBS='$(list --LDFLAGS --Wlrpath fftw-3) -lfftw3'"
    if $(is_c intel) ; then
        tmp="-L$MKL_PATH/lib/intel64 -Wl,-rpath=$MKL_PATH/lib/intel64"
	tmp=${tmp//\/\//}
	tmp_lib="$tmp_lib BLAS_LIBS='$tmp -mkl=sequential -lmkl_blas95_lp64'"
    	tmp_lib="$tmp_lib BLACS_LIBS='$tmp -mkl=sequential -lmkl_blacs_openmpi_lp64'"
	# Newer versions does not rely on separation of BLACS and ScaLAPACK
    	tmp_lib="$tmp_lib SCALAPACK_LIBS='$tmp -mkl=sequential -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
        tmp_lib="$tmp_lib LAPACK_LIBS='$tmp -mkl=sequential -lmkl_lapack95_lp64'"

    elif $(is_c gnu) ; then
	if [ $(pack_installed atlas) -eq 1 ] ; then
    	    pack_set --module-requirement atlas \
	        --module-requirement scalapack
    	    tmp_lib="$tmp_lib BLAS_LIBS='$(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas'"
    	    tmp_lib="$tmp_lib BLACS_LIBS='$(list --LDFLAGS --Wlrpath scalapack) -lscalapack'"
	    # Scalapack is already linked with BLACS...
    	    tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list --LDFLAGS --Wlrpath scalapack) -lscalapack'"
    	    tmp_lib="$tmp_lib LAPACK_LIBS='$(list --LDFLAGS --Wlrpath atlas) -llapack_atlas'"
	else
    	    pack_set --module-requirement blas --module-requirement lapack \
	        --module-requirement scalapack
    	    tmp_lib="$tmp_lib BLAS_LIBS='$(list --LDFLAGS --Wlrpath blas) -lblas'"
    	    tmp_lib="$tmp_lib BLACS_LIBS='$(list --LDFLAGS --Wlrpath scalapack) -lscalapack'"
	    # Scalapack is already linked with BLACS...
    	    tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list --LDFLAGS --Wlrpath scalapack) -lscalapack'"
    	    tmp_lib="$tmp_lib LAPACK_LIBS='$(list --LDFLAGS --Wlrpath lapack) -llapack'"
	fi

    else
	    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"
    fi

# Install commands that it should run
    pack_set --command "./configure" \
	--command-flag "$tmp_lib" \
	--command-flag "FFLAGS='$FCFLAGS'" \
	--command-flag "FFLAGS_NOOPT='-fPIC'" \
	--command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --module-paths-requirement))'" \
	--command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --module-paths-requirement))'" \
	--command-flag "--enable-parallel" \
	--command-flag "--prefix=$(pack_get --install-prefix)" 

    # Make commands
    for EXE in bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt ; do
	pack_set --command "make $(get_make_parallel) $EXE"
    done

    # Prepare installation directories...
    pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
    pack_set --command "cp bin/* $(pack_get --install-prefix)/bin/"

    pack_install

    create_module \
    	--module-path $(build_get --module-path)-npa-apps \
    	-n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    	-v $(pack_get --version) \
    	-M $(pack_get --alias).$(pack_get --version)/$(get_c) \
	-P "/directory/should/not/exist" \
    	$(list --prefix '-L ' $(pack_get --module-requirement)) \
    	-L $(pack_get --alias) 

done

