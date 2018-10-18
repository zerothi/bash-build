v=171221_1
add_package --package fhi-aims \
	    --directory fhi-aims.$v \
	    --version $v \
	    http://www.student.dtu.dk/~nicpa/packages/fhi-aims.$v.tgz

pack_set -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family fhi-aims"
pack_set --module-opt "--set-ENV FHIAIMS_VERSION=$v"
# FHI-aims complains about omp-num-threads even if it isn't used
pack_set --module-opt "--set-ENV OMP_NUM_THREADS=1"

pack_set --install-query $(pack_get --prefix)/bin/aims.$v.scalapack.mpi.x

pack_set --module-requirement mpi

# Create installation directory
pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# Go into src directory
pack_cmd "cd src"

tmp_arch="Generic"
if $(grep "sse" /proc/cpuinfo > /dev/null) ; then
    tmp_arch="AMD64_SSE"
fi
if $(grep "avx" /proc/cpuinfo > /dev/null) ; then
    tmp_arch="AMD64_AVX"
fi
if $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_arch="AMD64_AVX"
fi

# Prepare to use external input file
file=Makefile.nicpa
pack_cmd "sed -i '1 a\
include $file\n' Makefile"

# Write out the specific flags
pack_cmd "echo '# nicpa makefile' > $file"
pack_cmd "sed -i '$ a\
FC = $FC\n\
CC = $CC\n\
CFLAGS = $CFLAGS\n\
FFLAGS = $FFLAGS\n\
F90FLAGS = $FCLAGS\n\
MPIFC = $MPIFC\n\
MPICC = $MPICC\n\
USE_C_FILES = yes\n\
USE_MPI = yes\n\
USE_LIBXC = yes\n\
BINDIR = $(pack_get --prefix)/bin\n\
AUTODEPEND = yes\n\
ARCHITECTURE = $tmp_arch\n\
' $file"

if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
LAPACKBLAS = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_sequential\n\
SCALAPACK = $MKL_LIB -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64\n\
FFLAGS += -extend-source 132\n\
F90FLAGS += -extend-source 132\n\
' $file"

else
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    pack_cmd "sed -i '$ a\
LAPACKBLAS = $(list --LD-rp $la) $(pack_get -lib $la)\n\
SCALAPACK = $(list --LD-rp scalapack) -lscalapack\n\
FFLAGS += -ffree-line-length-none\n\
F90FLAGS += -ffree-line-length-none\n\
' $file"

fi

# Make commands
for target in libaims \
		  scalapack.libaims \
		  serial mpi scalapack.mpi multi.scalapack.mpi
do
    pack_cmd "make $(get_make_parallel) $target"
done


pack_cmd "cd $(pack_get --prefix)/bin"
pack_cmd 'chmod o-rwx *'
pack_cmd "ln -fs aims.$v.scalapack.mpi.x aims.x"
pack_cmd "ln -fs aims.$v.scalapack.mpi.x aims"
