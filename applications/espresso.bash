for v in 6.5 6.6 6.8 ; do
    tmp="-package q-espresso -version $v"
    case $v in
	6.2.1)
	    tmp="$tmp https://gitlab.com/QEF/q-e/-/archive/qe-6.2.1/q-e-qe-6.2.1.tar.bz2"
	    ;;
	6.1.0)
	    tmp="$tmp https://gitlab.com/QEF/q-e/-/archive/qe-6.1.0/q-e-qe-6.1.0.tar.bz2"
	    ;;
	5.4.0)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/211/968/espresso-5.4.0.tar.gz"
	    ;;
	5.3.0)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/204/912/espresso-5.3.0.tar.gz"
	    ;;
	5.2.1)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/199/855/espresso-5.2.1.tar.gz"
	    ;;
	5.1.2)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/185/753/espresso-5.1.2.tar.gz"
	    ;;
	5.1.1)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/173/655/espresso-5.1.1.tar.gz"
	    ;;
	5.1)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/151/581/espresso-5.1.tar.gz"
	    ;;
	5.0.3)
	    tmp="$tmp http://qe-forge.org/gf/download/frsrelease/116/403/espresso-5.0.2.tar.gz"
	    ;;
	5.0.99)
	    tmp="$tmp http://www.qe-forge.org/gf/download/frsrelease/151/519/espresso-5.0.99.tar.gz"
	    ;;
	6.*)
	    tmp="$tmp https://gitlab.com/QEF/q-e/-/archive/qe-$v/q-e-qe-$v.tar.bz2"
	    ;;
	*)
	    doerr q-espresso "Version unknown"
	    ;;
    esac

    add_package $tmp
    
    pack_set -install-query $(pack_get -prefix)/bin/pw.x

    pack_set -module-opt "-lua-family q-espresso"

    pack_set -module-requirement mpi 
    pack_set -module-requirement fftw

    # Fetch all the packages and pack them out
    source applications/espresso-packages.bash

    if [ -z "$FLAG_OMP" ]; then
	doerr q-espresso "Can not find the OpenMP flag (set FLAG_OMP in source)"
    fi
    tmp=

    # Check for Intel MKL or not
    tmp_lib="FFT_LIBS='$(list -LD-rp-lib[omp] fftw)'"
    # BLACS is always empty (fully encompassed in scalapack)
    tmp_lib="$tmp_lib BLACS_LIBS="
    if $(is_c intel) ; then
        tmp="$tmp -L$MKL_PATH/lib/intel64 -Wl,-rpath=$MKL_PATH/lib/intel64"
	tmp=${tmp//\/\//}
	tmp_lib="$tmp_lib BLAS_LIBS='$tmp -lmkl_blas95_lp64 -mkl=parallel'"
	# Newer versions does not rely on separation of BLACS and ScaLAPACK
    	tmp_lib="$tmp_lib SCALAPACK_LIBS='$tmp -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64'"
        tmp_lib="$tmp_lib LAPACK_LIBS='$tmp -lmkl_lapack95_lp64'"

    else
	pack_set -module-requirement scalapack

	la=lapack-$(pack_choice -i linalg)
	pack_set -module-requirement $la
	tmp_ld="$(list -LD-rp +$la)"
	tmp_lib="$tmp_lib LAPACK_LIBS='$tmp_ld $(pack_get -lib[omp] $la)'"
	tmp_lib="$tmp_lib SCALAPACK_LIBS='$(list -LD-rp scalapack) -lscalapack'"
	tmp_lib="$tmp_lib BLAS_LIBS='$tmp_ld $(pack_get -lib[omp] $la)'"

    fi

    # If we are in 6.0 we should fix CPV/src/forces.f90
    if [[ $(vrs_cmp $v 6.0.0) -le 0 ]]; then
	pack_cmd "sed -i -e '99,102s: \&:, \&:g' CPV/src/forces.f90"
    else
	pack_set -module-requirement libxc
	pack_set -module-requirement hdf5
	tmp_lib="$tmp_lib --with-libxc=yes --with-libxc-prefix=$(pack_get -prefix libxc)"
	tmp_lib="$tmp_lib --with-hdf5=yes --with-hdf5-libs='$(list -LD-rp hdf5) $(pack_get -lib[fortran] hdf5)'"
    fi

    # Install commands that it should run
    tmp="$tmp -D__FFTW3 ${FFLAGS//-floop-block/}"
    tmp="${tmp//-qopt-prefetch/}"
    tmp="${tmp//-opt-prefetch/}"
    tmp_inc="$(list -INCDIRS $(pack_get -mod-req-path))"
    pack_cmd "./configure" \
	 "$tmp_lib" \
	 "FFLAGS='$tmp $tmp_inc $FLAG_OMP'" \
	 "FFLAGS_NOOPT='-fPIC'" \
	 "FCFLAGS='$tmp $tmp_inc $FLAG_OMP'" \
	 "FCFLAGS_NOOPT='-fPIC'" \
	 "LDFLAGS='$(list -LD-rp $(pack_get -mod-req-path)) $FLAG_OMP'" \
	 "CPPFLAGS='$(list -INCDIRS $(pack_get -mod-req-path))'" \
	 "--enable-parallel --enable-openmp" \
	 "--prefix=$(pack_get -prefix)"

    # Make commands
    for EXE in $libs ; do
 	pack_cmd "make $(get_make_parallel) $EXE"
    done

    # Prepare installation directories...
    pack_cmd "mkdir -p $(pack_get -prefix)/bin"
    pack_cmd "mkdir -p $(pack_get -LD)"
    pack_cmd "mkdir -p $(pack_get -prefix)/include"
    if [[ $(vrs_cmp $v 6.0.0) -ge 0 ]]; then
	pack_cmd "make links"
	pack_cmd "make install"
    fi
    pack_cmd "cp bin/* $(pack_get -prefix)/bin/"
    pack_cmd "cp make.inc $(pack_get -prefix)/"
    # Install the iotk-library (not handled in install)
    pack_cmd "[ -d iotk ] && cp iotk/src/libiotk.a $(pack_get -LD)/ || true"
    pack_cmd "[ -d iotk ] && cp iotk/src/*.mod $(pack_get -prefix)/include/ || true"

done

