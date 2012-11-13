# http://qe-forge.org/gf/download/frsrelease/116/211/espresso-5.0.tar.gz \
for v in \
    http://qe-forge.org/gf/download/frsrelease/116/347/espresso-5.0.1.tar.gz ; do
    add_package $v
    
    pack_set -s $IS_MODULE

    pack_set --install-query $(pack_get --install-prefix)/bin/pw.x

    pack_set --module-requirement openmpi 
    pack_set --module-requirement fftw-serial-3

# Check for Intel MKL or not
    tmp=$(get_c)
    tmp_lib="FFT_LIBS='$(pack_get --install-prefix fftw-serial-3)/lib/libfftw3.a'"
    if [ "${tmp:0:5}" == "intel" ]; then
	tmp_lib="$tmp_lib BLAS_LIBS='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a'"
	tmp_lib="$tmp_lib BLACS_LIBS='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_blacs_openmpi_lp64.a'"
	tmp_lib="$tmp_lib SCALAPACK_LIBS='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_scalapack_lp64.a'"
	tmp_lib="$tmp_lib LAPACK_LIBS='-mkl=sequential $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a'"

    elif [ "${tmp:0:3}" == "gnu" ]; then
	pack_set --module-requirement lapack \
	    --module-requirement atlas \
	    --module-requirement scalapack
	tmp="$(pack_get --install-prefix atlas)"
	tmp_lib="$tmp_lib BLAS_LIBS='$tmp/lib/libf77blas.a $tmp/lib/libcblas.a $tmp/lib/libatlas.a'"
	tmp_lib="$tmp_lib BLACS_LIBS='$(pack_get --install-prefix)/lib/libscalapack.a'"
	tmp_lib="$tmp_lib SCALAPACK_LIBS='$(pack_get --install-prefix)/lib/libscalapack.a'"
	tmp_lib="$tmp_lib LAPACK_LIBS='$tmp/lib/liblapack_atlas.a'"
    fi

    tmp_ld=""
    tmp_cpp=""
    for cmd in $(pack_get --module-requirement) ; do
	tmp_ld="$tmp_ld -L$(pack_get --install-prefix $cmd)/lib"
	tmp_cpp="$tmp_cpp -I$(pack_get --install-prefix $cmd)/include"
    done

# Install commands that it should run
    pack_set --command "./configure" \
	--command-flag "$tmp_lib" \
	--command-flag "FFLAGS='$FCFLAGS'" \
	--command-flag "FFLAGS_NOOPT='-fPIC'" \
	--command-flag "LDFLAGS='$tmp_ld'" \
	--command-flag "CPPFLAGS='$tmp_cpp'" \
	--command-flag "--enable-parallel" \
	--command-flag "--prefix=$(pack_get --install-prefix)" 

    for EXE in bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt ; do
	pack_set --command "make $(get_make_parallel) $EXE"
    done

# Make commands
    pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
    pack_set --command "cp bin/* $(pack_get --install-prefix)/bin/"

    pack_install

done