v=2.1
add_package --package berkeley-GW -alias bgw -version $v \
	    -archive BerkeleyGW-$v.tar.gz \
	    https://public.boxcloud.com/d/1/b1!s2rQujU4Gj-1MsvjAOj_B8SC1yJJo0L44-kiy0jdTuptMdLzvH48dqsuZ-4ZGBqdxGRYZLl7G0nvIaR0TbQG7zxsXZ4_VIBo45FiRGUv3-EefLb3qmaKkX-AOQIsWpao0lMZwuAm4GgtZIOrj9_Wr0pUb9Xx03eclEnXjvs9733YJAOhucU3oCZ28MyF95_rN-E0QaVDB_fNIQYzSlbVKx_zmaQoMwHnooLEECidGhGy7u9skmq2_SoxyeP2VnvCBs-IK9vRsNeXzbrItkuv8OZMJA7ApdO7Q_sY_58HoAwoLMXWt_QLWPQ-H6HmZUw0boShY6hZyTtu0CbPRUM55WjrXwIciOrhbT3r3Xhhy4GUdV7H1nGsYSgaFtWLAcwA3RgL7ULk_O7Ggfhd9DtQQh-nZ0-fhrSKrWgEkdS5H-wKj-GYPFjTpptshnsFODQ7YVLs1wqTMZxhMGyJaLrtxOD92qqwjJtmMmVfryuv8ueKI8KbU05vdFQGDHSC-5k-hgm3y_C4xQJ7029X7w3-G5pexzjxKHd8pgEIPvT1LRclu0zXnj4heI4dr9-CgjFGIXl0wcrLTT90WToCx8XSA-qpYLpkEVV-JzbSDaSvwNpmy1y0oyOifcF88eLE3XMgdwEYKBmJox_sekoChQAa_6U60cOii-HoUqBWkQuy6h7P3hd4CxkXBI_wJ6muvOFFgMZJ5tTflrca-B1U4BD389knx03Puw4k-u3DuqwtYpvbDL9VyTuMx4doE4J978Lic1xNovr3wazwZAUTBf59JM16z23HWzGvzRUVRLZpHeAQ-Nx8QaAgxt6OyVUEgWegbpBD2f0cqI138GVjeLiVf6PS4a8D5zXMXFbfOls-9TOX1KAspPtck5zCzXdFjC_X_syq-arZWqklxvQttzOGn8qSneRXgUoQnohDTuvoiBoyuKCmtmhHokaUhcq0y-dnMHwSlWUSm8ASN0y5ZqI8nhAq4cFMEQM-KQDToYz7djYMgQ7Y7Fq5tMknJb9DTtOpf3ya-IjK9lVly_7oE5-_-GXCY1neok_plMdvcfu-mHTv8WGIgHT19ZpiN90JnaHYpI_KKmG7eADHVM0zObPJxhenCZ8vUyBbv948ROlmFTq8pkvrVfUj9yoIQUXozh848rtuGLuW4SnV0pjZ4NYwy2FMTj7MZlDj2GAcdIMZ1EK7KjosgtJ1FUWFFY44-soe7vgMYlAQfpTIRWBBIEOClfnmzJp-XUPlACdWgmwi5ngSABsjmrN3wnLU3b16PxLphKhNG4XdhzwSi4tCD0xKKA../download

pack_set -s $MAKE_PARALLEL

pack_set --module-opt "--lua-family bgw"

pack_set --install-query $(pack_get --prefix)/bin/epm.x

pack_set $(list -p '--module-requirement ' mpi fftw hdf5)

file=arch.mk
pack_cmd "echo '# NPA' > $file"

pack_cmd "sed -i '1 a\
PARAFLAG = -DMPI -DOMP\n\
MATHFLAG = -DUSESCALAPACK -DUSEFFTW3 -DHDF5\n\
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
FFTWLIB = $(list --LD-rp fftw) -lfftw3_omp -lfftw3\n\
FFTWINCLUDE = $(pack_get --prefix fftw)/include\n\
HDF5LIB = $(list --LD-rp hdf5 zlib) -lhdf5hl_fortran -lhdf5_hl -lhdf5_fortran -lhdf5 -lz\n\
HDF5INCLUDE = $(pack_get --prefix hdf5)/include\n\
TESTSCRIPT = MPIEXEC=\"$(pack_get --prefix mpi)/bin/mpirun\" make check-parallel\n\
' $file"

if $(is_c intel) ; then

    # PROBABLY FCPP is the cause of problems!
    pack_cmd "sed -i '$ a\
COMPFLAG = -DINTEL\n\
FCPP = $FC -C -E -P -xc\n\
LAPACKLIB = $MKL_LIB -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -mkl=sequential\n\
SCALAPACKLIB = -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 \$(LAPACKLIB) \n\
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
FCPP = cpp -P -nostdinc -C\n\
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
# Work-around for buggy makefile
# probably make manual isn't required, but we do it for consistency
pack_cmd "make manual"
pack_cmd "[ ! -e manual.html ] && cp documentation/users/manual.html ."

pack_cmd "make install INSTDIR=$(pack_get -prefix)"
