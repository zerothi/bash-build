v=2018.11.001
add_package -package elpa \
	    http://elpa.mpcdf.mpg.de/html/Releases/$v/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set -install-query $(pack_get -LD)/libelpa.a

pack_set -module-requirement mpi

if $(is_c intel) ; then
    # Here we need static blacs
    tmp="-lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread"
    if $(is_host slid muspel thul surt) ; then
        tmp="$tmp -L/usr/lib64"
    fi

else
    pack_set -module-requirement scalapack
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$(list -LD-rp scalapack $la) -lscalapack $(pack_get -lib[omp] $la)"
    
fi
tmp_flags="--enable-openmp"
if ! $(grep "sse" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-sse"
fi
if ! $(grep "avx" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-avx"
fi
if ! $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-avx2"
fi

# Fix remove_xcompiler
pack_cmd "sed -i -e 's/filter(\(.*\))/list(filter(\1))/' ../remove_xcompiler"

pack_cmd "../configure CPP='$CPP' CC='$MPICC' CFLAGS='$CFLAGS $FLAG_OMP' FC='$MPIFC' FCFLAGS='$FCFLAGS $FLAG_OMP' SCALAPACK_LDFLAGS='$tmp'" \
	 "$tmp_flags --prefix=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
if $(is_c intel) ; then
    pack_cmd "make install"
else
    pack_cmd "make check > elpa.test 2>&1 || echo forced"
    pack_cmd "make install"
    pack_store elpa.test
    pack_store test-suite.log elpa.test.log
fi

# Correct include paths
pack_cmd "cd $(pack_get -prefix)/include"
pack_cmd 'cd */'
pack_cmd "mv elpa ../"
pack_cmd "cp modules/* ../elpa/"

