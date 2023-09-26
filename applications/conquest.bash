v=1.2
add_package -package conquest \
    -version $v \
    https://github.com/OrderN/CONQUEST-release/releases/download/v$v/CONQUEST-release-$v.tar.gz

pack_set -module-opt "-lua-family conquest"

pack_set -install-query $(pack_get -prefix)/bin/Conquest

pack_set -module-requirement mpi -module-requirement fftw-mpi

# go into source directory
pack_cmd "cd src"

# libxc version should be 6
xc_v=6
pack_set -module-requirement libxc[$xc_v]

# Clean up the makefile
file=system.make
pack_cmd "echo '# build for DTU-hpc' > $file"

pack_cmd "sed -i '1 a\
FC=$MPIFC\n\
AR = $AR\n\
ARFLAGS = $ARFLAGS \n\
F77=$MPIFC\n\
COMPFLAGS = $FFLAGS \$(XC_COMPFLAGS)\n\
COMPFLAGS_F77 = $FFLAGS \$(XC_COMPFLAGS)\n\
FFT_OBJ = fft_fftw3.o\n\
FFT_LIB = $(list -LD-rp fftw-mpi) $(pack_get -lib fftw-mpi)\n\
XC_LIBRARY =LibXC_v5\n\
XC_LIB = $(list -LD-rp libxc[$xc_v]) $(pack_get -lib[f90] libxc[$xc_v])\n\
XC_COMPFLAGS = -I$(pack_get -prefix libxc[$xc_v])/include\n\
LIBS = \$(FFT_LIB) \$(XC_LIB) \$(SCA_LIB) \$(BLAS_LIB)\n' $file"

if $(is_c intel) ; then    
    # Added ifcore library to complie
    pack_cmd "sed -i '1 a\
BLAS_LIB = \n\
SCA_LIB = -qmkl=parallel\n' $file"
    
else
    pack_set -module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    pack_cmd "sed -i '1 a\
BLAS_LIB = $(list -LD-rp +$la) $(pack_get -lib $la)\n\
SCA_LIB = $(list -LD-rp scalapack) $(pack_get -lib scalapack)\n' $file"

fi

# prepare the directory of installation
pack_cmd "mkdir -p $(pack_get -prefix)/bin"

# Make commands
pack_cmd "make"
pack_cmd "cp ../bin/Conquest $(pack_get -prefix)/bin/"
