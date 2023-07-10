v=3.0.1
add_package -package berkeley-GW -alias bgw -version $v \
	    -archive BerkeleyGW-$v.tar.gz \
	    https://public.boxcloud.com/d/1/b1!jL6MbCWLxRk-NruqfNiFcWEmF9tUke62Iqd-H5uDq9dPG-LsR1BdE83udtYWzEKoH6L4flB3RQeA6eRAuPzwoLCmXWZmjPbMoHDRYqB2G1xW0X6TZ6Ue8SRAu0BLAYl-Kd5DnOAtoGqYe66Nd09ht9ZuLuuVOb12egOXsvqzjjXyQ3YH7MlfnLw5z72KeZE-cw5jYIgOxTm_7D071PU3OMtMEPPnTp7eaZRR1CeotXRvZSQpolrtNp0gD7yvmhK5NZAnBlBfKoX4zYltpWbuBA4RiFO32sgkTcJnSntXKu9Q71Gye_Mb_Qnq-htzYj0aFcwOrlOIZ0gzwPXD5vDgy3plLpemsaPYIwNFgEABEFre7U4jglb0Ca6LI5C-wzKE0_vZiEuflDYoQRldRbiNFuCreYTDXg1AfhzxeeYzE_n_0vF1qVaVJCnVEhoxOx7ErM7wwpkFk49iYGZXAERy9CiFRjfi-pjziF9Ju-HmlqnPITwjEoNXq21jEduN8vnKOgR2NL9DurBbAzsNHhhMS3H3vQpBc6iq9N1a6uy9gzFdiBFJiV-BQqAhGEeklfzSKkWrjAVMvOcwQWk9BSv7eh9DntR89NWFGThMLQ1aqmFlzgmiZxwptyrhqFuaJWrm-KGE5A2GHOaH2dX_c-65HInKCMTVVw19t_NoC5CrTbSvlfpuYrdv-et9YkjmuZR7vsVyLvpa5vS8hd8KzQFQE9Qg-F7Xxta7v77p7zgdgVEzjJjlBIXVBsrviclr1vqznqlRvVsbNnjgb6q45SbQbeS7fnOeP324UCcWqsC8k7-X-403BR4Yi7hkDvxoYQxTPDkW3Kc3uP0GdEtwES0PDIx5xj75sNIygzGFBw5c6j_3MrVy6RIdp1eDvCGL67ForpaapcfVMQ46SriGCwSckg9c8jQc1vpOVbILN-x6nDbMCIqHAz2AA10osVs_K1Bd80n1MRoDlBKL9uqHnZBnTjBqcg6jnFvtXgbbp0_53glfNzSpoin2OHjSgUAHARiHUzzD4mKopfYy8u3U3Rs0rUl3T8ZqTpr-Y4AnGB6D3tbQQARrlmG6_DqKc-c__Z82FecM3ogsi6OybQJzwCtUVerJYB-SDC8fGr8XVYgE_Vs4jdulyihxHGMahjmnzjTWMkUzdNzLwKNUslrlyOKNtvAkFHVhb4kyRLUCF1iUt-i4wmWUXkmV8lW439W7_2AX7OqD6qxijNTnZf-FPBz5zXcMzdbkctXcgZP1FFBGV0Sgko8l7bv8_U2X8x5OFmb32Bajysh4oYHhHqQ68cJxN8bqTqAmQVdvR2UOaU9Q78-tbShWdlIsqJs084g./download

pack_set -s $MAKE_PARALLEL

pack_set -module-opt "--lua-family bgw"

pack_set -install-query $(pack_get -prefix)/bin/epm.x

pack_set $(list -p '-module-requirement ' mpi fftw hdf5 elpa)

file=arch.mk
pack_cmd "echo '# NPA' > $file"

pack_cmd "sed -i '1 a\
PARAFLAG = -DMPI -DOMP\n\
MATHFLAG = -DUSESCALAPACK -DUSEFFTW3 -DHDF5 -DUSEELPA -DUNPACKED\n\
F90free = $MPIFC $FCFLAGS $FLAG_OMP\n\
LINK = $MPIFC $FLAG_OMP\n\
FOPTS = $FCFLAGS $FLAG_OMP\n\
FNOPTS = \$(FOPTS) \n\
MOD_OPT = -J\n\
INCFLAG = -I\n\
C_PARAFLAG = -DPARA\n\
CC_COMP = $MPICXX\n\
C_COMP = $MPICC\n\
C_LINK = $MPICXX $FLAG_OMP\n\
C_OPTS = $CFLAGS $FLAG_OMP\n\
C_DEBUGFLAG = \n\
REMOVE = rm -f\n\
FFTWLIB = $(list --LD-rp fftw) -lfftw3_omp -lfftw3\n\
FFTWINCLUDE = $(pack_get -prefix fftw)/include\n\
HDF5LIB = $(list --LD-rp hdf5 zlib) -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz\n\
HDF5INCLUDE = $(pack_get -prefix hdf5)/include\n\
ELPAINCLUDE = $(pack_get -prefix elpa)/include/elpa\n\
ELPALIB = $(list -LD-rp elpa) -lelpa\n\
TESTSCRIPT = MPIEXEC=\"$(pack_get -prefix mpi)/bin/mpirun\" make check-parallel\n\
' $file"

if $(is_c intel) ; then

    # PROBABLY FCPP is the cause of problems!
    pack_cmd "sed -i '$ a\
COMPFLAG = -DINTEL\n\
FCPP = $FC -C -E -P -xc\n\
LAPACKLIB = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -qmkl=sequential\n\
SCALAPACKLIB = -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 \$(LAPACKLIB) \n\
F90free += -free\n\
' $file"

elif $(is_c gnu) ; then
    pack_set -module-requirement scalapack

    # We use a c-linker (which does not add gfortran library)
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_ld="$(list -LD-rp scalapack +$la)"
    pack_cmd "sed -i '$ a\
COMPFLAG = -DGNU\n\
FCPP = cpp -P -nostdinc -nostdinc++ -C\n\
F90free += -ffree-form -ffree-line-length-none\n\
FOPTS   += -ffree-form -ffree-line-length-none\n\
SCALAPACKLIB = -lscalapack \$(LAPACKLIB) \n\
' $file"
    pack_cmd "sed -i '1 a\
LAPACKLIB = $tmp_ld $(pack_get -lib[omp] $la) -lgfortran \n\
' $file"

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi


pack_cmd "make all-flavors"
if $(is_host zero ntch) ; then
    pack_cmd "make BGW_TEST_MPI_NPROCS=$NPROCS check-jobscript 2>&1 > bgw.test || echo forced"
    pack_store bgw.test
fi
pack_cmd "touch manual.html ; make install INSTDIR=$(pack_get -prefix)"
