v=2.4p1
add_package --package eigenexa --version $v \
	    http://www.aics.riken.jp/labs/lpnctrt/assets/img/EigenExa-$v.tgz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libEigenExa.a

pack_set --module-requirement mpi

if $(is_c intel) ; then
    # Here we need static blacs
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    if $(is_host slid muspel surt) ; then
        tmp="$tmp -L/usr/lib64"
    fi

else
    
    pack_set --module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib $la)"
    
fi

flag=
for thread in none openmp
do
    if [[ $thread == "openmp" ]]; then
	# Add new flags
	flag="$FLAG_OMP"
	if $(is_c intel) ; then
	    tmp="${tmp//sequential/thread} -lpthread"
	else
	    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib[omp] $la)"
	fi
    fi
    # The ../src is a bug in the setup of the compilation
    pack_cmd "../configure CC='$MPICC -I../src' CFLAGS='$CFLAGS $flag' F77='$MPIFC -I../src' FFLAGS='$FFLAGS $flag' LIBS='$tmp $flag'" \
	     "LAPACK_LIBS='$tmp $flag' --prefix=$(pack_get --prefix)"
    
    pack_cmd "make $(get_make_parallel)"
    pack_cmd "make install"
    
    pack_cmd 'rm -rf *'

done

pack_set -lib -lEigenExa
pack_set -lib[omp] -lEigenExa_omp
