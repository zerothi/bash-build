# Install
add_package \
    --package mpb-serial \
    http://ab-initio.mit.edu/mpb/mpb-1.5.tar.gz

pack_set --host-reject ntch --host-reject zeroth

pack_set --install-query $(pack_get --prefix)/bin/mpbi

pack_set --module-opt "--lua-family mpb"

pack_set --module-requirement libctl \
    --module-requirement zlib \
    --module-requirement hdf5-serial \
    --module-requirement fftw-2

# Check for Intel MKL or not
tmp=
if $(is_c intel) ; then
    tmp="--with-blas='$MKL_LIB -mkl=sequential -lmkl_blas95_lp64'"
    tmp="$tmp --with-lapack='$MKL_LIB -mkl=sequential -lmkl_lapack95_lp64'"

elif $(is_c gnu) ; then

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LD-rp $la)"
	    tmp="$tmp --with-lapack='$tmp_ld -llapack'"
	    case $la in
		atlas)
		    tmp="$tmp --with-blas='$tmp_ld -lf77blas -lcblas -latlas'"
		    ;;
		openblas)
		    tmp="$tmp --with-blas='$tmp_ld -lopenblas'"
		    ;;
		blas)
		    tmp="$tmp --with-blas='$tmp_ld -lblas'"
		    ;;
	    esac
	    break
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
# Add the CTL library
tmp="$tmp --with-libctl=$(pack_get --prefix libctl)/share/libctl"

pack_cmd "module load build-tools"

# Install commands that it should run
pack_cmd "autoconf configure.ac > configure"
pack_cmd "./configure" \
     "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
     "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --mod-req-path))'" \
     "--without-mpi" \
     "--prefix=$(pack_get --prefix) $tmp" 

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Install the inversion symmetric part
pack_cmd "make distclean"
pack_cmd "./configure" \
     "LDFLAGS='$(list --LD-rp $(pack_get --mod-req-path))'" \
     "CPPFLAGS='-DH5_USE_16_API=1 $(list --INCDIRS $(pack_get --mod-req-path))'" \
     "--with-inv-symmetry" \
     "--without-mpi" \
     "--prefix=$(pack_get --prefix) $tmp" 

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "module unload build-tools"
