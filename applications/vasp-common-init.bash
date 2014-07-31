pack_set -s $IS_MODULE
pack_set --host-reject ntch --host-reject zeroth

pack_set --module-requirement openmpi
pack_set --module-requirement wannier90[1.2]

pack_set --module-opt "--lua-family vasp"

pack_set --install-query $(pack_get --install-prefix)/bin/vasp_tstGNGZhalf

file=mymakefile
pack_set --command "echo '# NPA' > $file"

# We can start by unpacking the stuff.
pack_set --command "tar xfz vasp.$v.tar.gz"
pack_set --command "tar xfz vasp.5.lib.tar.gz"

if [ $(vrs_cmp $v 5.3.5) -lt 0 ]; then
    # Correct the VDW algorithm, for the older versions
    pack_set --command "sed -i -e '268s/DO i=1/DO i=2/i' vasp.5.3/vdw_nl.F"
fi

# Start with creating a template makefile.
# The cache size is determined from the L1 cache (E5-2650 have ~64KB
# However, it has been investigated that a CACHE_SIZE of ~ 5000 is good for this
# L1 size.
pack_set --command "sed -i '1 a\
.SUFFIXES: .inc .f .f90 .F\n\
SUFFIX=.f90\n\
FC   = $MPIF90 $FLAG_OMP \n\
FCL  = \$(FC) \n\
CPP_ = fpp -f_com=no -free -w0 \$*.F \$*\$(SUFFIX) \n\
CPP  = \$(CPP_) -DMPI \\\\\n\
     -DCACHE_SIZE=6000 -Davoidalloc \\\\\n\
     -DMPI_BLOCK=60000 -Duse_collective -DscaLAPACK \\\\\n\
     -DRPROMU_DGEMV  -DRACCMU_DGEMV -DVASP2WANNIER90\n\
#PLACEHOLDER#\n\
FREE = -FR \n\
FFLAGS = $FCFLAGS -FR -assume byterecl \n\
OFLAG= $FCFLAGS \n\
OFLAG_HIGH = \$(OFLAG) \n\
OBJ_HIGH = \n\
OBJ_NOOPT = \n\
DEBUG  = -O0 \n\
INLINE = \$(OFLAG) \n\
WANNIER_PATH = $(pack_get --install-prefix wannier90[1.2])/lib\n\
WANNIER      = -L\$(WANNIER_PATH) -Wl,-rpath=\$(WANNIER_PATH)\n\
LIB  = -L../vasp.5.lib -ldmy \\\\\n\
     ../vasp.5.lib/linpack_double.o \$(SCA) \$(LAPACK) \$(BLAS) \$(WANNIER) -lwannier' $file"
    
# Check for Intel MKL or not
if $(is_c intel) ; then

    pack_set --command "sed -i '$ a\
# First correct the OpenMP flags\n\
FCL += -mkl=parallel \n\
DEBUG += -FR \n\
# Correct the CPP\n\
CPP += -DHOST=\\\\\"LinuxIFC\\\\\" -DPGF90 -DIFC \n\
# Setup MKL and libs\n\
MKL_PATH =$MKL_PATH\n\
MKL_LD =  -L\$(MKL_PATH)/lib/intel64 -Wl,-rpath=\$(MKL_PATH)/lib/intel64 \n\
BLAS = \$(MKL_LD) -lmkl_blas95_lp64 \n\
LAPACK = \$(MKL_LD) -lmkl_lapack95_lp64 \n\
SCA = \$(MKL_LD) -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \n\
LINK = $FLAG_OMP -mkl=parallel $(list --Wlrpath --LDFLAGS openmpi) ' $file"

else
    pack_set --command "sed -i '$ a\
# First correct the OpenMP flags\n\
# Correct the CPP\n\
CPP += -DHOST=\\\\\"$(get_c)\\\\\" \n\
LINK = $FLAG_OMP \n' $file"
    if [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	pack_set --command "sed -i '$ a\
SCA = $(list --Wlrpath --LDFLAGS openblas) -lscalapack\n\
BLAS = $(list --Wlrpath --LDFLAGS openblas) -lopenblas \n\
LAPACK = $(list --Wlrpath --LDFLAGS openblas) -llapack ' $file"
    elif [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '$ a\
SCA = $(list --Wlrpath --LDFLAGS atlas) -lscalapack\n\
BLAS = $(list --Wlrpath --LDFLAGS atlas) -lf77blas -lcblas -latlas \n\
LAPACK = $(list --Wlrpath --LDFLAGS atlas) -llapack ' $file"
    else
	pack_set --module-requirement blas
	pack_set --command "sed -i '$ a\
SCA = $(list --Wlrpath --LDFLAGS blas) -lscalapack\n\
BLAS = $(list --Wlrpath --LDFLAGS blas) -lblas \n\
LAPACK = $(list --Wlrpath --LDFLAGS blas) -llapack ' $file"
    fi
fi

