v=7.10.4
add_package http://ftp.abinit.org/abinit-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set $(list -p '--host-reject ' ntch zerothi n-62-25 n-62-26)

pack_set --module-opt "--lua-family abinit"

pack_set --install-query $(pack_get --prefix)/bin/abinit

pack_set --module-requirement mpi
pack_set --module-requirement gsl
pack_set --module-requirement atompaw
pack_set --module-requirement etsf_io
pack_set --module-requirement wannier90
pack_set --module-requirement fftw-mpi-3

# Correct mistakes in configure script...
pack_set --command "sed -i -e 's:= call nf90:= nf90:g' ../configure"

s="sed -i"
file=build.ac
pack_set --command "echo '# This is Nicks build.ac for Abinit' > $file"

if test -z "$FLAG_OMP" ; then
    doerr abinit "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi
tmpf="${FCFLAGS//-O3/-O2}"
tmpc="${CFLAGS//-O3/-O2}"
tmpcx="${CXXFLAGS//-O3/-O2}"
pack_set --command "$s '$ a\
prefix=\"$(pack_get --prefix)\"\n\
FC=\"$MPIFC\"\n\
CC=\"$MPICC\"\n\
CXX=\"$MPICXX\"\n\
FCFLAGS_EXTRA=\"${tmpf//-floop-block/} $FLAG_OMP\"\n\
CFLAGS_EXTRA=\"${tmpc//-floop-block/} $FLAG_OMP\"\n\
CXXFLAGS_EXTRA=\"${tmpcx//-floop-block/} $FLAG_OMP\"\n\
FCFLAGS_OPENMP=\"$FLAG_OMP\"\n\
FC_LDFLAGS_EXTRA=\"$(list --LD-rp $(pack_get --mod-req))\"\n\
enable_fc_wrapper=\"no\"\n\
enable_64bit_flags=\"yes\"\n\
enable_lotf=\"yes\"\n\
enable_openmp=\"yes\"\n\
enable_mpi_inplace=\"yes\"\n\
enable_mpi_io=\"yes\"\n\
enable_mpi=\"yes\"\n\
with_mpi_prefix=\"$(pack_get --prefix mpi)\"\n\
with_math_flavor=\"gsl\"\n\
with_linalg_flavor=\"custom\"\n\
with_math_incs=\"$(list --INCDIRS gsl)\"\n\
with_math_libs=\"$(list --LD-rp gsl) -lgsl\"\n' $file"
    
if $(is_c intel) ; then
    # We need to correct the configure script
    # (it checks whether linking is done correctly!)
    # STUPID, I say!
    #pack_set --command "$s -e 's/CFLAGS=\"/CFLAGS=\"-openmp /g' $file"
    pack_set --command "sed -i -e 's:\[LloW\]:[A-Za-z]:g' ../configure"
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
    pack_set --command "$s '$ a\
FCLIBS=\"$tmp\"\n\
LIBS=\"$tmp\"\n\
with_linalg_libs=\"$tmp\"\n' $file"
    # Ensures that the build will search for the correct MPI libraries
    pack_set --command "sed -i -e '/LDFLAGS_HINTS/{s:-static-intel::g;s:-static-libgcc::g}' ../configure"

else
    pack_set --module-requirement scalapack
    
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    if [ "x$la" == "xatlas" ]; then
		tmp="-lf77blas -lcblas -latlas"
	    elif [ "x$la" == "xopenblas" ]; then
		tmp="-lopenblas_omp"
	    elif [ "x$la" == "xblas" ]; then
		tmp="-lblas"
	    fi
	    pack_set --command "$s '$ a\
with_linalg_incs=\"$(list --INCDIRS $la)\"\n\
with_linalg_libs=\"$(list --LD-rp scalapack $la) -lscalapack -llapack $tmp\"\n' $file"
	    break
	fi
    done

fi

# Add default libraries
pack_set --command "$s '$ a\
with_trio_flavor=\"etsf_io+netcdf\"\n\
with_etsf_io_incs=\"$(list --INCDIRS etsf_io)\"\n\
with_etsf_io_libs=\"$(list --LD-rp etsf_io) -letsf_io -letsf_io_utils -letsf_io_low_level\"\n\
with_netcdf_incs=\"$(list --INCDIRS netcdf)\"\n\
with_netcdf_libs=\"$(list --LD-rp +netcdf) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\"\n\
with_fft_flavor=\"fftw3-mpi\"\n\
with_fft_incs=\"$(list --INCDIRS fftw-3)\"\n\
with_fft_libs=\"$(list --LD-rp fftw-3) -lfftw3f_omp -lfftw3f_mpi -lfftw3f -lfftw3_omp -lfftw3_mpi -lfftw3\"\n' $file"

dft_flavor=atompaw+wannier90
xc_version=$(pack_get --version libxc)
if [ $(vrs_cmp $xc_version 2.0.2) -ge 0 ]; then
    pack_set --module-requirement libxc
    dft_flavor="$dft_flavor+libxc"
    xclib="-lxc"
    if [ $(vrs_cmp $xc_version 2.2.0) -ge 0 ]; then
	xclib="-lxcf90 -lxc"
	# Correct the check for the minor version
	pack_set --command "sed -i -e 's/minor != 0/minor != $(str_version -2 $xc_version)/' ../configure"
	pack_set --command "sed -i -e 's/|| (minor < 0) || (minor > 1)//' ../configure"

    fi
    pack_set --command "$s '$ a\
with_libxc_incs=\"$(list --INCDIRS libxc)\"\n\
with_libxc_libs=\"$(list --LD-rp libxc) $xclib\"' $file"
fi

if [ $(vrs_cmp $(pack_get --version bigdft) 1.7) -lt 0 ]; then
    # The interface for the later versions
    # has changed, hence we require the old-version
    pack_set --module-requirement bigdft
    dft_flavor="$dft_flavor+bigdft"
    pack_set --command "$s '$ a\
with_bigdft_incs=\"$(list --INCDIRS bigdft)\"\n\
with_bigdft_libs=\"$(list --LD-rp bigdft) -lbigdft-1\"' $file"
    
fi

pack_set --command "$s '$ a\
with_dft_flavor=\"$dft_flavor\"\n\
with_atompaw_bins=\"$(pack_get --prefix atompaw)/bin\"\n\
with_atompaw_incs=\"$(list --INCDIRS atompaw)\"\n\
with_atompaw_libs=\"$(list --LD-rp atompaw) -latompaw\"\n\
with_wannier90_bins=\"$(pack_get --prefix wannier90)/bin\"\n\
with_wannier90_incs=\"$(list --INCDIRS wannier90)\"\n\
with_wannier90_libs=\"$(list --LD-rp wannier90) -lwannier\"' $file"

# Configure the package...
# We must not override the flags on the command line, it will
# disturb the automatically added flags...
pack_set --command "unset FCFLAGS && unset CFLAGS && ../configure --with-config-file=./$file"

if $(is_c intel) ; then
    # Correct the compilation for the intel compiler
    pack_set --command "sed -i -e 's:-O[23]:-O1:g' src/66_wfs/Makefile"
fi

# Make commands
tmp=$(get_make_parallel)
pack_set --command "make multi multi_nprocs=${tmp//-j /}"
# With 7.8+ the testing system has changed.
# We should do some python calls...
#pack_set --command "make check-local > tmp.test 2>&1" # only check local tests...
#pack_set_mv_test tmp.test
pack_set --command "make install"
