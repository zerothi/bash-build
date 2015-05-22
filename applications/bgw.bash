v=1.1b2
add_package --package berkeley-GW -alias bgw -version $v \
    --directory BerkeleyGW-1.1-beta2 \
    http://www.student.dtu.dk/~nicpa/packages/BGW-1.1-beta2.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family bgw"

pack_set --host-reject ntch
pack_set --host-reject zerothi

pack_set --install-query $(pack_get --prefix)/bin/bgw

pack_set $(list -p '--module-requirement ' mpi fftw-3 hdf5)

file=arch.mk
pack_set --command "echo '# NPA' > $file"

pack_set --command "sed -i '1 a\
PARAFLAG = -DMPI\n\
MATHFLAG = -DUSESCALAPACK -DUSEFFTW3 -DHDF5\n\
FCPP = /usr/bin/cpp -ansi\n\
F90free = $MPIFC $FCFLAGS\n\
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
FFTWLIB = $(list --LD-rp fftw-3) -lfftw3_omp -lfftw3\n\
FFTWINCLUDE = $(pack_get --prefix fftw-3)/include\n\
HDF5LIB = $(list --LD-rp hdf5 zlib) -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz\n\
HDF5INCLUDE = $(pack_get --prefix hdf5)/include\n\
TESTSCRIPT = MPIEXEC=\"$(pack_get --prefix mpi)/bin/mpirun\" make check-parallel\n\
' $file"

if $(is_c intel) ; then

    pack_set --command "sed -i '$ a\
COMPFLAG = -DINTEL\n\
LAPACKLIB = -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential\n\
SCALAPACKLIB = -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \$(LAPACKLIB) \n\
' $file"

elif $(is_c gnu) ; then

    # We use a c-linker (which does not add gfortran library)
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    tmp_ld="$(list --LD-rp $la)"
	    pack_set --command "sed -i '$ a\
COMPFLAG = -DGNU\n\
F90free += -ffree-form -ffree-line-length-none\n\
FOPTS   += -ffree-form -ffree-line-length-none\n\
SCALAPACKLIB = -lscalapack \$(LAPACKLIB) \n\
' $file"
	    if [ "x$la" == "xatlas" ]; then
		pack_set --command "sed -i '1 a\
LAPACKLIB = $tmp_ld -llapack -lf77blas -lcblas -latlas -lgfortran \n\
' $file"
	    elif [ "x$la" == "xopenblas" ]; then
		pack_set --command "sed -i '1 a\
LAPACKLIB = $tmp_ld -llapack -lopenblas_omp -lgfortran \n\
' $file"
	    elif [ "x$la" == "xblas" ]; then
		pack_set --command "sed -i '1 a\
LAPACKLIB = $tmp_ld -llapack -lblas -lgfortran \n\
' $file"
	    fi
	    break
	fi
    done

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
fi

pack_set --command "make all-flavors"
pack_set --command "make BGW_TEST_MPI_NPROCS=$NPROCS check-jobscript 2>&1 > tmp.test ; echo 'Success'"
pack_set_mv_test tmp.test
pack_set --command "make install INSTDIR=$(pack_get --prefix)"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)
