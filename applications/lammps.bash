# For completion of the version string...
# However, a first install should be fine...
# rm .archives/lammps.tar.gz
add_package -package lammps \
	    -directory 'lammps-*' \
	    -archive lammps-2019.05.15.tar.gz \
	    https://github.com/lammps/lammps/archive/patch_15May2019.tar.gz

pack_set_file_version
pack_set -s $MAKE_PARALLEL -s $BUILD_DIR

pack_set -module-opt "-lua-family lammps"

pack_set -install-query $(pack_get -prefix)/bin/lmp

pack_set -build-mod-req build-tools
pack_set -module-requirement mpi \
	 -module-requirement fftw
#	 -module-requirement netcdf

# Fix OpenMP shared declarations (OpenMP 5 forced declaration of all variables)
pack_cmd "pushd ../src/"
pack_cmd "sh USER-OMP/hack_openmp_for_pgi_gcc9.sh"
pack_cmd "cd USER-OMP"
pack_cmd "sh ./hack_openmp_for_pgi_gcc9.sh"
pack_cmd "popd"

_tmp_flags=
function _lammps_flags {
    _tmp_flags="$_tmp_flags $@"
}

_lammps_flags -DBUILD_EXE=yes
_lammps_flags -DBUILD_LIB=yes
_lammps_flags -DBUILD_SHARED_LIBS=yes
_lammps_flags -DBUILD_OMP=yes
_lammps_flags -DBUILD_MPI=yes

_lammps_flags -DLAMMPS_MACHINE=mpi
_lammps_flags -DCMAKE_CXX_COMPILER=$CXX
_lammps_flags -DCMAKE_C_COMPILER=$CC
_lammps_flags -DCMAKE_Fortran_COMPILER=$FC
_lammps_flags -DCMAKE_CXX_FLAGS="'$CFLAGS'"
_lammps_flags -DCMAKE_C_FLAGS="'$CFLAGS'"
_lammps_flags -DCMAKE_Fortran_FLAGS="'$FCFLAGS'"
_lammps_flags -DFFT=FFTW3
# force double precision
_lammps_flags -DFFT_SINGLE=no
_lammps_flags -DFFTW3_INCLUDE_DIRS=$(pack_get -prefix fftw-mpi)/include
_lammps_flags -DFFTW3_LIBRARIES=$(pack_get -prefix fftw-mpi)/lib
# Allows handling lammps as library (otherwise LAMMPS dies!)
_lammps_flags -DLAMMPS_EXCEPTIONS=yes

# Enable packages
# NetCDF produces wrong linker args! :(
#_lammps_flags -DNETCDF_INCLUDE_DIR=$(pack_get -prefix netcdf)/include
#_lammps_flags -DNETCDF_LIBRARY=$(pack_get -prefix netcdf)/lib
#_lammps_flags -DPKG_USER-NETCDF=yes

# Define install directory
_lammps_flags -DCMAKE_INSTALL_PREFIX="$(pack_get -prefix)"

pack_cmd "cmake $_tmp_flags ../cmake"
unset _lammps_flags
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Add potential files and env-var
pack_set -module-opt "-set-ENV LAMMPS_POTENTIALS=$(pack_get -prefix)/potentials"
pack_cmd "cp -rf ../potentials $(pack_get -prefix)/"

pack_cmd "cd $(pack_get -prefix)/bin"
pack_cmd "ln -s lmp_mpi lmp"

