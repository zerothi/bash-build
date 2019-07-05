v=2018.11.001
add_package -package elpa \
	    http://elpa.mpcdf.mpg.de/html/Releases/$v/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libelpa.a

pack_set -module-requirement mpi

# Specify libraries
pack_set -lib -lelpa
pack_set -lib[omp] -lelpa_openmp

# Fix remove_xcompiler
pack_cmd "sed -i -e 's/filter(\(.*\))/list(filter(\1))/' ../remove_xcompiler"

tmp_flags=
if ! $(grep "sse" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-sse"
fi
if ! $(grep "avx" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-avx"
fi
if ! $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-avx2"
fi

if ! $(is_c intel) ; then
    la=scalapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
fi    

for omp in openmp serial ; do
    pack_cmd "rm -rf ./*"
    
    tmp=
    if $(is_c intel) ; then
	# Here we need static blacs
	tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
	tmp="$tmp -lmkl_intel_lp64 -lmkl_core"
	case $omp in
	    openmp)
		tmp="$tmp -lmkl_intel_thread"
		;;
	    *)
		tmp="$tmp -lmkl_sequential"
		;;
	esac
    else
	case $omp in
	    openmp)
		tmp="$tmp $(list -LD-rp +$la) $(pack_get -lib[omp] $la)"
		;;
	    *)
		tmp="$tmp $(list -LD-rp +$la) $(pack_get -lib $la)"
		;;
	esac
    fi

    case $omp in
	openmp)
	    pack_cmd "../configure CPP='$CPP' CC='$MPICC' CFLAGS='$CFLAGS $FLAG_OMP' FC='$MPIFC' FCFLAGS='$FCFLAGS $FLAG_OMP' SCALAPACK_LDFLAGS='$tmp'" \
		     "$tmp_flags --enable-openmp --prefix=$(pack_get -prefix)"
	    ;;
	*)
	    pack_cmd "../configure CPP='$CPP' CC='$MPICC' CFLAGS='$CFLAGS' FC='$MPIFC' FCFLAGS='$FCFLAGS' SCALAPACK_LDFLAGS='$tmp'" \
		     "$tmp_flags --prefix=$(pack_get -prefix)"
	    ;;
    esac
    pack_cmd "make $(get_make_parallel)"
    if $(is_c intel) ; then
	pack_cmd "make install"
    else
	pack_cmd "make check > elpa.$omp.test 2>&1 || echo forced"
	pack_cmd "make install"
	pack_store elpa.$omp.test
	pack_store test-suite.log elpa.$omp.test.log
    fi

done

# Correct include paths
pack_cmd "cd $(pack_get -prefix)/include"
pack_cmd "ln -s elpa-$v/elpa elpa"
pack_cmd "cd elpa"
pack_cmd 'for f in ../elpa-$v/modules/*.mod ; do ln -s \$f . ; done'
