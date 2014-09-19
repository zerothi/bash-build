for v in 5.1 ; do
    libs="bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt"
    if [ "$v" = "5.1" ]; then
	tmp="-package espresso -version $v http://www.qe-forge.org/gf/download/frsrelease/151/581/espresso-5.1.tar.gz"
	libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra acfdt"
    elif [ "$v" = "5.0.3" ]; then
	tmp="-package espresso -version $v http://qe-forge.org/gf/download/frsrelease/116/403/espresso-5.0.2.tar.gz"
    elif [ "$v" = "5.0.99" ]; then
	tmp=http://www.qe-forge.org/gf/download/frsrelease/151/519/espresso-5.0.99.tar.gz
    else
	doerr espresso "Version unknown"
    fi

    add_package $tmp
    
    pack_set -s $IS_MODULE

    pack_set --install-query $(pack_get --install-prefix)/bin/pw.x

    pack_set --host-reject ntch --host-reject zeroth

    pack_set --module-opt "--lua-family espresso"

    pack_set --module-requirement openmpi 
    pack_set --module-requirement fftw-3

    # Fetch all the packages and pack them out
    source applications/espresso-packages.bash

    if test -z "$FLAG_OMP" ; then
	doerr espresso "Can not find the OpenMP flag (set FLAG_OMP in source)"
    fi

    # Check for Intel MKL or not
    tmp_lib="FFT_LIBS='$(list --LDFLAGS --Wlrpath fftw-3) -lfftw3'"
    # BLACS is always empty (fully encompassed in scalapack)
    tmp_lib="$tmp_lib BLACS_LIBS="
    if $(is_c intel) ; then
        tmp="-L$MKL_PATH/lib/intel64 -Wl,-rpath=$MKL_PATH/lib/intel64"
	tmp=${tmp//\/\//}
	tmp_lib="$tmp_lib BLAS_LIBS='$tmp -lmkl_blas95_lp64 -mkl=parallel'"
	# Newer versions does not rely on separation of BLACS and ScaLAPACK
    	tmp_lib="$tmp_lib SCALAPACK_LIBS='$tmp -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
        tmp_lib="$tmp_lib LAPACK_LIBS='$tmp -lmkl_lapack95_lp64'"

    else

	if [ $(pack_installed atlas) -eq 1 ]; then
	    pack_set --module-requirement atlas
    	    tmp_lib="$tmp_lib BLAS_LIBS='$(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas'"
    	    tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list --LDFLAGS --Wlrpath atlas) -lscalapack'"
    	    tmp_lib="$tmp_lib LAPACK_LIBS='$(list --LDFLAGS --Wlrpath atlas) -llapack'"
	elif [ $(pack_installed openblas) -eq 1 ]; then
	    pack_set --module-requirement openblas
    	    tmp_lib="$tmp_lib BLAS_LIBS='$(list --LDFLAGS --Wlrpath openblas) -lopenblas'"
    	    tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list --LDFLAGS --Wlrpath openblas) -lscalapack'"
    	    tmp_lib="$tmp_lib LAPACK_LIBS='$(list --LDFLAGS --Wlrpath openblas) -llapack'"
	else
	    pack_set --module-requirement blas
    	    tmp_lib="$tmp_lib BLAS_LIBS='$(list --LDFLAGS --Wlrpath blas) -lblas'"
    	    tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list --LDFLAGS --Wlrpath nblas) -lscalapack'"
    	    tmp_lib="$tmp_lib LAPACK_LIBS='$(list --LDFLAGS --Wlrpath blas) -llapack'"
	fi

    fi

    # Install commands that it should run
    pack_set --command "./configure" \
	--command-flag "$tmp_lib" \
	--command-flag "FFLAGS='$FCFLAGS $FLAG_OMP'" \
	--command-flag "FFLAGS_NOOPT='-fPIC'" \
	--command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --module-paths-requirement)) $FLAG_OMP'" \
	--command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --module-paths-requirement))'" \
	--command-flag "--enable-parallel --enable-openmp" \
	--command-flag "--prefix=$(pack_get --install-prefix)" 

    # Make commands
    for EXE in $libs ; do
 	pack_set --command "make $(get_make_parallel) $EXE"
    done

    # Prepare installation directories...
    pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
    pack_set --command "mkdir -p $(pack_get --install-prefix)/lib"
    pack_set --command "mkdir -p $(pack_get --install-prefix)/include"
    pack_set --command "cp bin/* $(pack_get --install-prefix)/bin/"
    # Install the iotk-library
    pack_set --command "cp iotk/src/libiotk.a $(pack_get --library-path)/"
    pack_set --command "cp iotk/src/*.mod $(pack_get --install-prefix)/include/"

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

