add_package --build debug http://pstl.cs.uh.edu/projects/adcl-2.0.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --LD)/libadcl.a

pack_set --module-requirement mpi

pack_cmd "module load $(pack_get --module-name build-tools)"

# Install commands that it should run
pack_cmd "./configure CC=$CC MPICC=$MPICC --prefix=$(pack_get --prefix)" \
	 "--enable-printf-tofile" \
	 "--enable-userlevel-timings" \
	 "--with-num-tests=1" \
	 "--enable-dummy-mpi" \
	 "--disable-fortran" \
	 "--with-mpi-dir=$(pack_get --prefix mpi)" \
	 "--with-mpi-f90='$MPIFC'" \
	 "--with-mpi-cc='$MPICC'" \
	 "--with-mpi-cxx='$MPICXX'"

# Fix MPI_BYTE
pack_cmd "sed -i -e 's/\(#define MPI_INT \)/#define MPI_BYTE (MPI_Datatype)30\n\1/' include/ADCL_dummy_mpi.h"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Copy over the dummy MPI header
pack_cmd "cp include/ADCL_dummy_mpi.h $(pack_get --prefix)/include/"

pack_cmd "module unload $(pack_get --module-name build-tools)"
