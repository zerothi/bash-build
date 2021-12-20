v=2.11
add_package --package eigenexa --version $v \
        https://www.r-ccs.riken.jp/labs/lpnctrt/projects/eigenexa/EigenExa-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libEigenExa.a

pack_set --build-mod-req build-tools
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

tmp_flags=
if $(grep "avx" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx"
fi
if $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --enable-avx2"
fi

pack_cmd "./bootstrap"

flag=
for thread in none openmp
do
    if [[ $thread == "openmp" ]]; then
	# Add new flags
	flag="$FLAG_OMP"
	if $(is_c intel) ; then
	    tmp="${tmp//sequential/intel_thread} -lpthread"
	else
	    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib[omp] $la)"
	fi
    fi
    # The ../src is a bug in the setup of the compilation
    pack_cmd "./configure CC='$MPICC' CFLAGS='$CFLAGS $flag' F77='$MPIFC $FCFLAGS $flag' FC='$MPIFC $FCFLAGS $flag' FCFLAGS='$FCFLAGS $flag'  FFLAGS='$FFLAGS $flag' LIBS='$tmp $flag'" \
	     "LAPACK_LIBS='$tmp $flag' --prefix=$(pack_get --prefix)"

    if [[ $thread == "none" ]]; then
	# Remove all OpenMP mentions in the makefile
	pack_cmd "sed -i -s -e 's/$FLAG_OMP//g' **/Makefile"
    fi
    
    pack_cmd "make $(get_make_parallel)"
    pack_cmd "make install"

    case $thread in
	none)
	    pack_cmd "pushd $(pack_get --prefix)/lib"
	    pack_cmd 'for f in lib* ; do mv $f s_$f ; done'
	    pack_cmd "popd"
	    ;;
	openmp)
	    pack_cmd "pushd $(pack_get --prefix)/lib"
	    pack_cmd 'for f in lib* ; do mv $f ${f//.*}_omp.${f##*.} ; mv s_$f $f ; done'
	    pack_cmd "popd"
	    ;;
    esac
    pack_cmd 'make clean'

done

pack_set -lib -lEigenExa
pack_set -lib[omp] -lEigenExa_omp
