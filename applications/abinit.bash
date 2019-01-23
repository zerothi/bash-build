for v in 8.10.2
do
add_package https://www.abinit.org/sites/default/files/packages/abinit-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family abinit"

pack_set --install-query $(pack_get --prefix)/bin/abinit

pack_set --module-requirement mpi
pack_set --module-requirement gsl
pack_set --module-requirement atompaw
pack_set --module-requirement wannier90
pack_set --module-requirement fftw-mpi

# Correct mistakes in configure script...
pack_cmd "sed -i -e 's:= call nf90:= nf90:g' ../configure"
s="sed -i"
file=build.ac

for mpila in elpa scalapack
do

# clean up the previous compilation
pack_cmd "rm -rf *"

pack_cmd "echo '# This is Nicks build.ac for Abinit' > $file"

if [[ -z "$FLAG_OMP" ]]; then
    doerr abinit "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi
tmpf="${FCFLAGS//-O3/-O2}"
tmpc="${CFLAGS//-O3/-O2}"
tmpcx="${CXXFLAGS//-O3/-O2}"
pack_cmd "$s '$ a\
prefix=\"$(pack_get --prefix)\"\n\
FC=\"$MPIFC\"\n\
CC=\"$MPICC\"\n\
CXX=\"$MPICXX\"\n\
FCFLAGS_EXTRA=\"${tmpf//-floop-block/} $FLAG_OMP -I$(pack_get --prefix mpi)/include\"\n\
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

# Create LINALG libraries
if [[ $mpila == elpa ]]; then
    pack_set --module-requirement elpa
    tmp="$(list --LD-rp elpa)"
    tmp="$tmp -lelpa"
    tmp_inc="$(list --INCDIRS elpa)"
else
    tmp_inc=
    tmp=
fi
pack_set --module-requirement plasma
tmp="$tmp $(list --LD-rp plasma)"
tmp="$tmp -lplasma -lcoreblasqw -lcoreblas -lquark"
tmp_inc="$tmp_inc $(list --INCDIRS plasma)"
    
if $(is_c intel) ; then
    # We need to correct the configure script
    # (it checks whether linking is done correctly!)
    # STUPID, I say!
    #pack_cmd "$s -e 's/CFLAGS=\"/CFLAGS=\"-openmp /g' $file"
    pack_cmd "sed -i -e 's:\[LloW\]:[A-Za-z]:g' ../configure"
    if [[ $mpila == elpa ]]; then
	tmp="$tmp $INTEL_LIB $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
    else
	tmp="$tmp $INTEL_LIB $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=parallel"
    fi
    pack_cmd "$s '$ a\
FCLIBS=\"$tmp\"\n\
LIBS=\"$tmp\"\n\
with_linalg_libs=\"$tmp\"\n' $file"
    # Ensures that the build will search for the correct MPI libraries
    pack_cmd "sed -i -e '/LDFLAGS_HINTS/{s:-static-intel::g;s:-static-libgcc::g}' ../configure"

else
    if [[ $mpila == scalapack ]]; then
	pack_set --module-requirement scalapack
	tmp="$tmp $(list --LD-rp scalapack) -lscalapack"
    fi
    
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_inc="$tmp_inc $(list --INCDIRS ++$la)"
    tmp="$tmp $(pack_get -lib[lapacke] $la) $(pack_get -lib[omp] $la)"
    pack_cmd "$s '$ a\
with_linalg_libs=\"$(list --LD-rp ++$la) $tmp\"\n' $file"

fi

pack_cmd "$s '$ a\
with_linalg_incs=\"$tmp_inc\"\n' $file"

# Add default libraries
pack_cmd "$s '$ a\
with_trio_flavor=\"netcdf\"\n\
with_netcdf_incs=\"$(list --INCDIRS netcdf)\"\n\
with_netcdf_libs=\"$(list --LD-rp ++netcdf) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\"\n\
with_fft_flavor=\"fftw3-mpi\"\n\
with_fft_incs=\"$(list --INCDIRS fftw-mpi)\"\n\
with_fft_libs=\"$(list --LD-rp fftw-mpi) -lfftw3f_omp -lfftw3f_mpi -lfftw3f -lfftw3_omp -lfftw3_mpi -lfftw3\"\n' $file"


_xc_v=3.0.1
dft_flavor=atompaw+wannier90+libxc
pack_set --module-requirement libxc[$_xc_v]
xclib="-lxcf90 -lxc"
pack_cmd "$s '$ a\
with_libxc_incs=\"$(list --INCDIRS libxc[$_xc_v])\"\n\
with_libxc_libs=\"$(list --LD-rp libxc[$_xc_v]) $xclib\"' $file"


if [[ $(vrs_cmp $(pack_get --version bigdft) 1.7) -lt 0 ]]; then
    # The interface for the later versions
    # has changed, hence we require the old-version
    pack_set --module-requirement bigdft
    dft_flavor="$dft_flavor+bigdft"
    pack_cmd "$s '$ a\
with_bigdft_incs=\"$(list --INCDIRS bigdft)\"\n\
with_bigdft_libs=\"$(list --LD-rp bigdft) -lbigdft-1\"' $file"
    
fi

pack_cmd "$s '$ a\
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
pack_cmd "unset FCFLAGS && unset CFLAGS && ../configure --with-config-file=./$file"

if $(is_c intel) ; then
    # Correct the compilation for the intel compiler
    pack_cmd "sed -i -e 's:-O[23]:-O1:g' src/66_wfs/Makefile src/98_main/Makefile"
fi

# Make commands
tmp=$(get_make_parallel)
pack_cmd "make multi multi_nprocs=${tmp//-j /}"

# With 7.8+ the testing system has changed.
# We should do some python calls...
tmp="--loglevel=INFO -v -v -n $NPROCS --pedantic"
pack_cmd "pushd tests"
pack_cmd "../../tests/runtests.py $tmp fast 2>&1 > $mpila.fast.test ; echo succes"
pack_set_mv_test $mpila.fast.test

if ! $(is_c intel) ; then
    pack_cmd "../../tests/runtests.py $tmp atompaw libxc wannier90 2>&1 > $mpila.in.test ; echo succes"
    pack_set_mv_test $mpila.in.test

    pack_cmd "../../tests/runtests.py $tmp v1 2>&1 > $mpila.v1.test ; echo succes"
    pack_set_mv_test $mpila.v1.test
fi
pack_cmd "popd"

pack_cmd "make install"
pack_cmd "pushd $(pack_get --prefix)/bin"
pack_cmd "mv abinit abinit_$mpila"
pack_cmd "popd"

pack_cmd "cp $file $(pack_get --prefix)/${mpila}_${file}"

done

pack_cmd "pushd $(pack_get --prefix)/bin"
pack_cmd "ln -s abinit_elpa abinit"
pack_cmd "popd"

done
