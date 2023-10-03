# 8.10.3 is broken
# The current format only conforms to 9.X
for v in 9.10.3
do
add_package https://www.abinit.org/sites/default/files/packages/abinit-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -module-opt "-lua-family abinit"

pack_set -install-query $(pack_get -prefix)/bin/abinit

pack_set -module-requirement libxml2
pack_set -module-requirement mpi
pack_set -module-requirement gsl
w90_v=3
pack_set -module-requirement wannier90[$w90_v]
pack_set -module-requirement fftw-mpi
pack_set -module-requirement netcdf
pack_set -module-requirement xmlf90
# configure fails due to missing psml_die code
pack_set -module-requirement libpsml
pack_set -module-requirement libxc

# Correct mistakes in configure script...
s="sed -i"
pack_cmd "$s -e 's:= call nf90:= nf90:g;s:100[*]4[+]2:100*4+3:' ../configure"
file=$(hostname -s).ac9

pack_cmd "module load python"

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
prefix=\"$(pack_get -prefix)\"\n\
FC=\"$MPIFC\"\n\
CC=\"$MPICC\"\n\
CXX=\"$MPICXX\"\n\
FCFLAGS_EXTRA=\"${tmpf//-floop-block/} -I$(pack_get -prefix mpi)/include\"\n\
CFLAGS_EXTRA=\"${tmpc//-floop-block/}\"\n\
CXXFLAGS_EXTRA=\"${tmpcx//-floop-block/}\"\n\
FCFLAGS_OPENMP=\"$FLAG_OMP\"\n\
FC_LDFLAGS_EXTRA=\"$(list -LD-rp $(pack_get -mod-req))\"\n\
with_libxml2=\"$(pack_get -prefix libxml2)\"\n\
LIBXML2_CPPFLAGS=\"$(list -INCDIRS gsl)\"\n\
LIBXML2_LIBS=\"$(list -LD-rp libxml2) -lxml2\"\n\
enable_fc_wrapper=\"no\"\n\
enable_lotf=\"no\"\n\
enable_openmp=\"no\"\n\
enable_mpi_inplace=\"yes\"\n\
with_mpi_inplace=\"yes\"\n\
# The code does not implement level=3\n\
with_mpi_level=\"2\"\n\
with_mpi_io=\"yes\"\n\
with_mpi=\"$(pack_get -prefix mpi)\"\n\
#with_linalg_flavor=\"custom\"\n\
#with_math_incs=\"$(list -INCDIRS gsl)\"\n\
#with_math_libs=\"$(list -LD-rp gsl) -lgsl\"\n' $file"

# on https://github.com/abinit/abinit/issues/32 it is suggested to not use lotf

# Create LINALG libraries
if [[ $mpila == elpa ]]; then
    pack_set -module-requirement elpa
    tmp="$(list -LD-rp elpa)"
    tmp="$tmp -lelpa"
    tmp_inc="$(list -INCDIRS elpa)/elpa"
else
    tmp=
    tmp_inc=
fi
    
if $(is_c intel) ; then
    # We need to correct the configure script
    # (it checks whether linking is done correctly!)
    # STUPID, I say!
    #pack_cmd "$s -e 's/CFLAGS=\"/CFLAGS=\"-openmp /g' $file"
    pack_cmd "sed -i -e 's:\[LloW\]:[A-Za-z]:g' ../configure"
    if [[ $mpila == elpa ]]; then
	tmp="$tmp $INTEL_LIB $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -qmkl=parallel"
    else
	tmp="$tmp $INTEL_LIB $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -qmkl=parallel"
    fi
    pack_cmd "$s '$ a\
FCLIBS=\"$tmp\"\n\
LIBS=\"$tmp\"\n\
LINALG_LDFLAGS=\"$tmp\"\n\
LINALG_LIBS=\"$tmp\"\n' $file"
    # Ensures that the build will search for the correct MPI libraries
    pack_cmd "sed -i -e '/LDFLAGS_HINTS/{s:-static-intel::g;s:-static-libgcc::g}' ../configure"

else
	  pack_set -module-requirement scalapack
	  tmp="$tmp $(list -LD-rp scalapack) -lscalapack"
    
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_inc="$tmp_inc $(list -INCDIRS ++$la)"
    tmp="$tmp $(pack_get -lib[lapacke] $la) $(pack_get -lib[omp] $la)"
    pack_cmd "$s '$ a\
LINALG_LDFLAGS=\"$(list -LD-rp ++$la) $tmp\"\n\
LINALG_LIBS=\"$(list -LD-rp ++$la) $tmp\"\n' $file"

fi

pack_cmd "$s '$ a\
LINALG_CPPFLAGS=\"$tmp_inc\"\n\
LINALG_FCFLAGS=\"$tmp_inc\"\n' $file"

# Add default libraries
pack_cmd "$s '$ a\
HDF5_CPPFLAGS=\"$(list -INCDIRS hdf5)\"\n\
HDF5_LIBS=\"$(list -LD-rp ++hdf5) -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\"\n\
NETCDF_CPPFLAGS=\"$(list -INCDIRS netcdf)\"\n\
NETCDF_LIBS=\"$(list -LD-rp ++netcdf) -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\"\n\
NETCDF_FORTRAN_CPPFLAGS=\"$(list -INCDIRS netcdf)\"\n\
NETCDF_FORTRAN_FCFLAGS=\"$(list -INCDIRS netcdf)\"\n\
NETCDF_FORTRAN_LIBS=\"$(list -LD-rp ++netcdf) -lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\"\n\
FFTW3_CPPFLAGS=\"$(list -INCDIRS fftw-mpi)\"\n\
FFTW3_LIBS=\"$(list -LD-rp fftw-mpi) -lfftw3f_mpi -lfftw3f -lfftw3_mpi -lfftw3 -lfftw3_threads\"\n' $file"


# Please see the following dependencies to ensure no duplicate
# libxc versions are being used!
#   atompaw
#   bigdft
pack_cmd "$s '$ a\
LIBXC_CPPFLAGS=\"$(list -INCDIRS libxc)\"\n\
LIBXC_FCFLAGS=\"$(list -INCDIRS libxc)\"\n\
LIBXC_LIBS=\"$(list -LD-rp libxc) $(pack_get -lib[f90] libxc)\"' $file"

pack_cmd "$s '$ a\
XMLF90_CPPFLAGS=\"$(list -INCDIRS xmlf90)\"\n\
XMLF90_FCFLAGS=\"$(list -INCDIRS xmlf90)\"\n\
XMLF90_LIBS=\"$(list -LD-rp xmlf90) $(pack_get -lib xmlf90)\"' $file"

#pack_cmd "$s '$ a\
#LIBPSML_CPPFLAGS=\"$(list -INCDIRS libpsml)\"\n\
#LIBPSML_FCFLAGS=\"$(list -INCDIRS libpsml)\"\n\
#LIBPSML_LIBS=\"$(list -LD-rp libpsml) $(pack_get -lib libpsml)\"' $file"

pack_cmd "$s '$ a\
WANNIER90_CPPFLAGS=\"$(list -INCDIRS wannier90[$w90_v])\"\n\
WANNIER90_FCFLAGS=\"$(list -INCDIRS wannier90[$w90_v])\"\n\
WANNIER90_LIBS=\"$(list -LD-rp wannier90[$w90_v]) -lwannier\"' $file"


# Configure the package...
# We must not override the flags on the command line, it will
# disturb the automatically added flags...
pack_cmd "unset FCFLAGS ; unset CFLAGS ; unset CPPFLAGS ; unset LDFLAGS"
pack_cmd "../configure --with-config-file=./$file"

if $(is_c intel) ; then
    # Correct the compilation for the intel compiler
    pack_cmd "sed -i -e 's:-O[23]:-O1:g' src/66_wfs/Makefile src/98_main/Makefile"
fi

# Make commands
pack_cmd "make $(get_make_parallel)"

# With 7.8+ the testing system has changed.
# We should do some python calls...
tmp="--loglevel=INFO -v -v -n $NPROCS --pedantic"
pack_cmd "pushd tests"
# create a small virtual environment
pack_cmd "python -m pip install --user -U virtualenv"
pack_cmd "python -m virtualenv abinit_venv"
pack_cmd "source abinit_venv/bin/activate"
pack_cmd "pip install pandas"

pack_cmd "../../tests/runtests.py $tmp fast 2>&1 > $mpila.fast.test || echo forced"
pack_store $mpila.fast.test

if ! $(is_c intel) ; then
    pack_cmd "../../tests/runtests.py $tmp libxc wannier90 2>&1 > $mpila.in.test || echo forced"
    pack_store $mpila.in.test

    pack_cmd "../../tests/runtests.py $tmp v1 2>&1 > $mpila.v1.test || echo forced"
    pack_store $mpila.v1.test
fi
pack_cmd "deactivate ; popd"

pack_cmd "make install"
pack_cmd "pushd $(pack_get -prefix)/bin"
pack_cmd "mv abinit abinit_$mpila"
pack_cmd "popd"

pack_cmd "cp $file $(pack_get -prefix)/${mpila}_${file}"

done

pack_cmd "module unload python"

pack_cmd "pushd $(pack_get -prefix)/bin"
pack_cmd "ln -s abinit_elpa abinit"
pack_cmd "popd"

done
