for v in 5.1.1 ; do
    libs="bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt"
    tmp="-package espresso -version $v"
    if [ "$v" = "5.1.2" ]; then
	tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/185/753/espresso-5.1.2.tar.gz"
    elif [ "$v" = "5.1.1" ]; then
	tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/173/655/espresso-5.1.1.tar.gz"
    elif [ "$v" = "5.1" ]; then
	tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/151/581/espresso-5.1.tar.gz"
    elif [ "$v" = "5.0.3" ]; then
	tmp="$tmp http://qe-forge.org/gf/download/frsrelease/116/403/espresso-5.0.2.tar.gz"
    elif [ "$v" = "5.0.99" ]; then
	tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/151/519/espresso-5.0.99.tar.gz"
    else
	doerr espresso "Version unknown"
    fi

    add_package $tmp
    
    pack_set --install-query $(pack_get --prefix)/bin/pw.x

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

	for la in $(choice linalg) ; do
	    if [ $(pack_installed $la) -eq 1 ] ; then
		pack_set --module-requirement $la
		tmp_ld="$(list --LDFLAGS --Wlrpath $la)"
		tmp_lib="$tmp_lib LAPACK_LIBS='$tmp_ld -llapack'"
		tmp_lib="$tmp_lib SCALAPACK_LIBS='$tmp_ld -lscalapack'"
		if [ "x$la" == "xatlas" ]; then
		    tmp_lib="$tmp_lib BLAS_LIBS='$tmp_ld -lf77blas -lcblas -latlas'"
		elif [ "x$la" == "xopenblas" ]; then
		    tmp_lib="$tmp_lib BLAS_LIBS='$tmp_ld -lopenblas_omp'"
		elif [ "x$la" == "xblas" ]; then
		    tmp_lib="$tmp_lib BLAS_LIBS='$tmp_ld -lblas'"
		fi
		break
	    fi
	done

    fi

    # Install commands that it should run
    pack_set --command "./configure" \
	--command-flag "$tmp_lib" \
	--command-flag "FFLAGS='$FCFLAGS $FLAG_OMP'" \
	--command-flag "FFLAGS_NOOPT='-fPIC'" \
	--command-flag "LDFLAGS='$(list --Wlrpath --LDFLAGS $(pack_get --mod-req-path)) $FLAG_OMP'" \
	--command-flag "CPPFLAGS='$(list --INCDIRS $(pack_get --mod-req-path))'" \
	--command-flag "--enable-parallel --enable-openmp" \
	--command-flag "--prefix=$(pack_get --prefix)" 

    # Fix kvecs_FS.f for gfortran loop-block
    if $(is_c gnu) ; then
        pack_set --command "sed -i '$ a\
kvecs_FS.o: FFLAGS=${FCFLAGS//-floop-block/}\n' make.sys"
    fi

    # Make commands
    for EXE in $libs ; do
 	pack_set --command "make $(get_make_parallel) $EXE"
    done

    # Prepare installation directories...
    pack_set --command "mkdir -p $(pack_get --prefix)/bin"
    pack_set --command "mkdir -p $(pack_get --LD)"
    pack_set --command "mkdir -p $(pack_get --prefix)/include"
    pack_set --command "cp bin/* $(pack_get --prefix)/bin/"
    # Install the iotk-library
    pack_set --command "cp iotk/src/libiotk.a $(pack_get --LD)/"
    pack_set --command "cp iotk/src/*.mod $(pack_get --prefix)/include/"

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

