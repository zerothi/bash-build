for v in 5.3.3 ; do
add_package http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip

pack_set -s $IS_MODULE

pack_set --alias vasp
pack_set --host-reject ntch
pack_set --directory VASP
pack_set --version $(pack_get --version)-fftw3.3.2
pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/vasp

pack_set --module-requirement fftw[3.3.2]

tmp=$(pack_get --alias)-$(pack_get --version).make

# We can start by unpacking the stuff..
pack_set --command "tar xvfz vasp.5.3.3.tar.gz"
pack_set --command "tar xvfz vasp.5.lib.tar.gz"

# Start with creating a template makefile.
# The cache size is determined from the L1 cache (E5-2650 have ~64KB
# However, it has been investigated that a CACHE_SIZE of ~ 5000 is good for this
# L1 size.
cat <<EOF > $tmp
.SUFFIXES: .inc .f .f90 .F
SUFFIX=.f90
FC   = $MPIF90 
FCL  = \$(FC) 
CPP_ = fpp -f_com=no -free -w0 \$*.F \$*\$(SUFFIX) 
CPP  = \$(CPP_) -DMPI \
     -DCACHE_SIZE=5000 -Davoidalloc \
     -DMPI_BLOCK=8000 -Duse_collective -DscaLAPACK \
     -DRPROMU_DGEMV  -DRACCMU_DGEMV
#PLACEHOLDER#
FREE = -FR 
FFLAGS = $FCFLAGS -FR -assume byterecl 
OFLAG= $FCFLAGS 
OFLAG_HIGH = \$(OFLAG) 
OBJ_HIGH = 
OBJ_NOOPT = 
DEBUG  = -O0 
INLINE = \$(OFLAG) 
LIB  = -L../vasp.5.lib -ldmy \
     ../vasp.5.lib/linpack_double.o \$(SCA) \$(LAPACK) \$(BLAS)
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \
      $(pack_get --install-prefix fftw[3.3.2])/lib/libfftw3.a
INCS    = -I$(pack_get --install-prefix fftw[3.3.2])/include
EOF
    
# Check for Intel MKL or not
if $(is_c intel) ; then

    cat <<EOF >> $tmp
# First correct the OpenMP flags
FCL += -mkl=parallel -openmp 
FFLAGS += -openmp 
DEBUG += -FR 
# Correct the CPP
CPP += -DHOST=\"LinuxIFC\" -DPGF90 -DIFC 
# Setup MKL and libs
MKL_PATH =$MKL_PATH
MKL_LD =  -L\$(MKL_PATH)/lib/intel64 -Wl,-rpath=\$(MKL_PATH)/lib/intel64 
BLAS = \$(MKL_LD) -lmkl_blas95_lp64 
LAPACK = \$(MKL_LD) -lmkl_lapack95_lp64 
SCA = \$(MKL_LD) -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 
LINK = -openmp -mkl=parallel 
EOF

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack
    cat <<EOF >> $tmp
# First correct the OpenMP flags
FCL += -fopenmp 
FFLAGS += -fopenmp 
# Correct the CPP
CPP += -DHOST=\"gfortran\" 
LINK = -fopenmp 
SCA = $(list --Wlrpath --LDFLAGS scalapack) -lscalapack 
EOF
    if $(pack_exists atlas) ; then
	pack_set --module-requirement atlas
	cat <<EOF >> $tmp
BLAS = $(list --Wlrpath --LDFLAGS atlas) -lcblas -lf77blas -latlas 
LAPACK = $(list --Wlrpath --LDFLAGS atlas) -llapack_atlas 
EOF
    else
	pack_set --module-requirement blas
	pack_set --module-requirement lapack
	cat <<EOF >> $tmp
BLAS = $(list --Wlrpath --LDFLAGS blas) -lblas 
LAPACK = $(list --Wlrpath --LDFLAGS lapack) -llapack 
EOF
    fi

else
    doerr VASP "Could not find compiler $(get_c)"

fi

pack_set --command "mv $(pwd)/$tmp ./mymakefile"
pack_set --command "cd vasp.5.lib"

# Now tmp will hold the makefile name
tmp=makefile.linux_ifc_P4

# Do library installation
# Install the makefile...
pack_set --command "sed -i -e 's:# general.*:\n\
FC=$FC\n\
CC=$CC\n\
CFLAGS=$CFLAGS\n\
FCFLAGS=$FCFLAGS -FI -O0:' $tmp"
pack_set --command "make -f $tmp"
pack_set --command "cd ../vasp.5.3"

# Prepare the installation directory
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

# Make commands
# Install the makefile
pack_set --command "sed -i -e 's:# general.*:include ../mymakefile:' $tmp"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp"
pack_set --command "make -f $tmp clean"

# Prepare next installation (apparantly this is only for the serial version)
#pack_set --command "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGXHALF:' ../mymakefile"
#pack_set --command "make -f $tmp"
#pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspNGXHALF"
#pack_set --command "make -f $tmp clean"

# Prepare next installation (apparantly this is only for the serial version)
#pack_set --command "sed -i -e 's:NGXHALF:NGXHALF -DwNGXHALF:' ../mymakefile"
#pack_set --command "make -f $tmp"
#pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspGNGXHALF"
#pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGZHALF :' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspNGZHALF"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZHALF:NGZHALF -DwNGZHALF:' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspGNGZHALF"
pack_set --command "make -f $tmp clean"

pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)

done