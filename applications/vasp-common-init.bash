pack_set -s $IS_MODULE
pack_set --alias vasp
pack_set --host-reject ntch
pack_set --directory VASP

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --module-requirement openmpi

pack_set --install-query $(pack_get --install-prefix)/bin/vasp

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
LINK = -openmp -mkl=parallel $(list --Wlrpath --LDFLAGS openmpi) 
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

