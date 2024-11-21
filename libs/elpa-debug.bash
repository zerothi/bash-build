for v in 2024.05.001 2022.11.001
do
add_package --build debug --package elpa-debug \
	    http://elpa.mpcdf.mpg.de/html/Releases/$v/elpa-$v.tar.gz

pack_set -s $IS_MODULE -s $BUILD_DIR

pack_set --install-query $(pack_get --LD)/libelpa.a

pack_set --module-requirement mpi

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
if ! $(grep "avx512" /proc/cpuinfo > /dev/null) ; then
    tmp_flags="$tmp_flags --disable-avx512"
fi


tmp=
if $(is_c intel) ; then
    # Here we need static blacs
    tmp="$tmp -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64"
    tmp="$tmp -lmkl_intel_lp64 -lmkl_core -lmkl_sequential"
    if $(is_host slid muspel thul surt) ; then
        tmp="$tmp -L/usr/lib64"
    fi

else
    la=scalapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$tmp $(list -LD-rp +$la) $(pack_get -lib $la)"
fi

# We cannot use OpenMP threading as it requires sequential BLAS
pack_cmd "../configure CPP='$CPP' CXX='$MPICXX' CXXFLAGS='$CXXFLAGS' CC='$MPICC' CFLAGS='$CFLAGS' FC='$MPIFC' FCFLAGS='$FCFLAGS' SCALAPACK_LDFLAGS='$tmp'" \
     "$tmp_flags --prefix=$(pack_get -prefix)"

# This will fail, we have to circumvent it
pack_cmd "make $(get_make_parallel) || echo forced"
# Fix
pack_cmd "sed -i 's/_COMPILED@) \\\\//g;s/@//g' elpa/elpa_constants.h"
pack_cmd "make clean"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "cd $(pack_get --prefix)/include"
pack_cmd 'cd */'
pack_cmd "mv elpa ../"
pack_cmd "cp modules/* ../elpa/"

done
