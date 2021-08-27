add_package -package adcl -version 0 \
	    https://github.com/PSTL-UH/ADCL.git

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libadcl.a

pack_set -build-mod-req build-tools
pack_set -module-requirement mpi

# Install commands that it should run
pack_cmd "CC=$CC MPICC=$MPICC ./configure --prefix=$(pack_get -prefix)" \
	 "--enable-printf-tofile" \
	 "--with-num-tests=1" \
	 "--enable-userlevel-timings" \
	 "--enable-dummy-mpi" \
	 "--disable-fortran" \
	 "--with-mpi-dir=$(pack_get -prefix mpi)" \
	 "--with-mpi-f90='$MPIFC'" \
	 "--with-mpi-cc='$MPICC'" \
	 "--with-mpi-cxx='$MPICXX'"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
