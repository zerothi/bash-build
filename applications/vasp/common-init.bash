# Ensure this is only installed at DTU
if ! $(is_host n- surt muspel slid) ; then
    pack_set --host-reject $(get_hostname)
fi

if $(is_c gnu) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_set --host-reject ntch --host-reject zeroth

pack_set --module-requirement mpi
pack_set --module-requirement wannier90


pack_set --module-opt "--lua-family vasp"

pack_set --install-query $(pack_get --prefix)/bin/vasp_tstGNGZhalf_is2

file=mymakefile
pack_cmd "echo '# NPA' > $file"

# We can start by unpacking the stuff.
pack_cmd "tar xfz vasp.$v.tar.gz"
pack_cmd "tar xfz vasp.5.lib.tar.gz"

if [[ $(vrs_cmp $v 5.3.5) -lt 0 ]]; then
    # Correct the VDW algorithm, for the older versions
    pack_cmd "sed -i -e '268s/DO i=1/DO i=2/i' vasp.5.3/vdw_nl.F"
fi

# Start with creating a template makefile.
# The cache size is determined from the L1 cache (E5-2650 have ~64KB
# However, it has been investigated that a CACHE_SIZE of ~ 5000 is good for this
# L1 size.
pack_cmd "sed -i '1 a\
FC   = $MPIF90 $FLAG_OMP \n\
FCL  = \$(FC) \n\
CPP_ = fpp -f_com=no -free -w0 \$*.F \$*\$(SUFFIX) \n\
CPP  = \$(CPP_) -DMPI \\\\\n\
     -DCACHE_SIZE=6000 -Davoidalloc \\\\\n\
     -DMPI_BLOCK=60000 -Duse_collective -DscaLAPACK \\\\\n\
     -DRPROMU_DGEMV -DRACCMU_DGEMV -DVASP2WANNIER90\n\
#PLACEHOLDER#\n\
CPP_OPTIONS += -DDGEGV=DDGGEV\n\
CFLAGS = $CFLAGS \n\
FFLAGS = $FCFLAGS \n\
OFLAG  = \$(FFLAGS) \n\
OFLAG_HIGH = \$(OFLAG) \n\
OBJ_HIGH  = \n\
OBJ_NOOPT = \n\
DEBUG  = -O0 \n\
INLINE = \$(OFLAG) \n\
WANNIER_PATH = $(pack_get --LD wannier90)\n\
WANNIER      = -L\$(WANNIER_PATH) -Wl,-rpath=\$(WANNIER_PATH)\n\
LIB  = -L../vasp.5.lib -ldmy \$(WANNIER) -lwannier \\\\\n\
     ../vasp.5.lib/linpack_double.o \$(SCA) \$(LAPACK) \$(BLAS)' $file"
    
# Check for Intel MKL or not
if $(is_c intel) ; then

    pack_cmd "sed -i '$ a\
FFLAGS_SPEC1 = -FR -lowercase -O1\n\
FFLAGS_SPEC2 = -FR -lowercase -O2\n\
FREE = -FR\n\
FCL += -mkl=parallel \n\
FFLAGS += -FR -assume byterecl \n\
DEBUG += -FR \n\
# Correct the CPP\n\
CPP += -DHOST=\\\\\"LinuxIFC\\\\\" -DPGF90 -DIFC \n\
# Setup MKL and libs\n\
MKL_PATH = $MKL_PATH\n\
MKL_LD =  -L\$(MKL_PATH)/lib/intel64 -Wl,-rpath=\$(MKL_PATH)/lib/intel64 \n\
BLAS = \$(MKL_LD) -lmkl_blas95_lp64 \n\
LAPACK = \$(MKL_LD) -lmkl_lapack95_lp64 \n\
SCA = \$(MKL_LD) -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \n\
LINK = $FLAG_OMP -mkl=parallel $(list --LD-rp mpi) ' $file"

elif $(is_c gnu) ; then

    pack_cmd "sed -i '$ a\
FFLAGS_SPEC1 = -O1\n\
FFLAGS_SPEC2 = -O2\n\
LIB += -fall-intrinsics\n\
CPP_ =  ./preprocess <\$*.F | cpp -P -C -traditional >\$*\$(SUFFIX)\n\
# Correct flags for gfortran\n\
FFLAGS += -ffree-form -ffree-line-length-0 -ff2c\n\
FREE = -ffree-form\n\
FCL = \$(FC)\n\
# Correct the CPP\n\
CPP += -DHOST=\\\\\"$(get_c)\\\\\" \n\
LINK = $FLAG_OMP $(list --LD-rp mpi)\n\
LINK = \n\
DEBUG = \n' $file"
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '$ a\
SCA = $(list --LD-rp scalapack) -lscalapack\n\
LAPACK = $(list --LD-rp +$la) $(pack_get -lib[omp] $la)\n\
BLAS = \$(LAPACK)\n' $file"

# Fix source for gnu
pack_cmd "sed -i -e 's:3(1x,3I):3(1x,3I0):g' vasp.5.3/spinsym.F"
pack_cmd "sed -i -e '1463s/USE us/USE us, only: setdij_/' vasp.5.3/us.F"
pack_cmd "sed -i -e '2696s/USE us/USE us, only: augmentation_charge/' vasp.5.3/us.F"
pack_cmd "sed -i -e \"661s:'W':'W ':\" vasp.5.3/vdwforcefield.F"
pack_cmd "sed -i -e '1657s:(I):(I0):' vasp.5.3/finite_diff.F"
pack_cmd "sed -i -e '1041s:(I,:(I0,:' vasp.5.3/fcidump.F"
pack_cmd "sed -i -e 's:==\.FALSE\.:.eqv..FALSE.:gi' vasp.5.3/ump2.F"

else
    do_err "VASP" "Unknown compiler: $(get_c)"
fi

