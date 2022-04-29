for par in serial mpi cuda serial-plumed mpi-plumed cuda-plumed
do

case $par in
    serial)
	tmp_add_package=""
	;;
    serial-plumed)
	tmp_add_package="-package gromacs-plumed"
	;;
    mpi)
	tmp_add_package="-package gromacs-mpi"
	;;
    mpi-plumed)
	tmp_add_package="-package gromacs-plumed-mpi"
	;;
    cuda)
	tmp_add_package="-package gromacs-cuda -build cuda"
	# Check if we have build
	if $(build_exist cuda) ; then
	    noop
	else
	    msg_install -message "Skipping CUDA build for gromacs!"
	    continue
	fi
	;;
    cuda-plumed)
	tmp_add_package="-package gromacs-plumed-cuda -build cuda"
	# Check if we have build
	if $(build_exist cuda) ; then
	    noop
	else
	    msg_install -message "Skipping CUDA build for gromacs-plumed!"
	    continue
	fi
	;;
esac

for v in 2020.6 2021.5 2022.1 ; do
add_package $tmp_add_package ftp://ftp.gromacs.org/pub/gromacs/gromacs-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL

pack_set -module-opt "-lua-family gromacs"

pack_set -install-query $(pack_get -prefix)/bin/GMXRC

pack_set -build-mod-req build-tools
pack_set -module-requirement fftw


# fix building with a newer gcc (limits inclusion missing)
if [[ $(vrs_cmp $v 2020.6) -le 0 ]]; then
    pack_cmd "sed -i -e '/#include <algorithm>/a #include <limits>' ../src/gromacs/awh/biasparams.cpp"
    pack_cmd "sed -i -e '/#include <algorithm>/a #include <limits>' ../src/gromacs/mdrun/minimize.cpp"
    pack_cmd "sed -i -e '/#include <queue>/a #include <limits>' ../src/gromacs/modularsimulator/modularsimulator.h"
fi


tmp="-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) -DGMX_BUILD_OWN_FFTW=OFF"

case $par in
    mpi*)
	pack_set -module-requirement mpi
	tmp="$tmp -DGMX_MPI=ON -DNUMPROC=$((NPROCS/2))"
	# for 2019
	tmp="$tmp -DHWLOC_INCLUDE_DIRS=$(pack_get -prefix hwloc)/include"
	tmp="$tmp -DHWLOC_LIBRARIES=$(pack_get -LD hwloc)/libhwloc.a"
	# for 2020
	tmp="$tmp -DHWLOC_DIR=$(pack_get -prefix hwloc)"
	;;
    cuda*)
	tmp="$tmp -DGMX_GPU=ON -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME"
	;;
esac
tmp="$tmp -DBUILD_SHARED_LIBS=ON"

case $par in
    *-plumed)
	pack_set -mod-req plumed
	# Run the patch
	if [[ $(vrs_cmp $(pack_get -version plumed) 2.5.1) -ge 0 ]]; then
	    if [[ $(vrs_cmp $v 2018) -eq 0 ]]; then
	    pack_cmd "pushd .. ; echo 2 | plumed patch -p ; popd"
        else
		pack_set -host-reject $(get_hostname)
	    fi
	else
	    doerr $(pack_get -package) "Failed to get the correct version of plumed for GROMACS"
	fi
	;;
esac

tmp="$tmp -DGMX_PREFER_STATIC_LIBS=ON"
tmp="$tmp -DGMX_FFT_LIBRARY=fftw3"

# Allow 256 threads (default 32)
tmp="$tmp -DGMX_OPENMP=ON"
tmp="$tmp -DGMX_OPENMP_MAX_THREADS=256"

if $(is_c intel) ; then
    # hopefully this should be enough
    tmp="$tmp -DGMX_LAPACK_USER='-mkl=parallel'"
    tmp="$tmp -DGMX_BLAS_USER='-mkl=parallel'"
    
elif $(is_c gnu) ; then
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp_ld="$(list -LD-rp +$la)"
    tmp="$tmp -DGMX_LAPACK_USER='$(trim_spaces $tmp_ld) $(pack_get -lib[omp] $la)'"
    tmp="$tmp -DGMX_BLAS_USER='$(trim_spaces $tmp_ld) $(pack_get -lib[omp] $la) -lgfortran -lm'"

else
    doerr $(pack_get -package) "Could not determine compiler: $(get_c)"
    
fi

if $(grep "avx512" /proc/cpuinfo > /dev/null) ; then
    tmp="$tmp -DGMX_SIMD=AVX_512"
elif $(grep "avx2" /proc/cpuinfo > /dev/null) ; then
    tmp="$tmp -DGMX_SIMD=AVX2_256"
elif $(grep "sse4_1" /proc/cpuinfo > /dev/null) ; then
    tmp="$tmp -DGMX_SIMD=SSE4.1"
elif $(grep "sse" /proc/cpuinfo > /dev/null) ; then
    tmp="$tmp -DGMX_SIMD=SSE2"
fi

clib="$(list -prefix ':' -loop-cmd 'pack_get -LD' $(pack_get -mod-req))"
clib=${clib// /}
clib=${clib:1}

# configure the build...
pack_cmd "CXXFLAGS='$CXXFLAGS' cmake .. $tmp -DCMAKE_PREFIX_PATH='$clib'"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

case $par in
    serial*|cuda*)
	pack_cmd "OMP_NUM_THREADS=$NPROCS make check > gromacs.test || echo forced"
	;;
    mpi*)
	pack_cmd "OMP_NUM_THREADS=$((NPROCS/2)) make check > gromacs.test || echo forced"
	;;
esac
    
pack_store gromacs.test


# Add GROMACS envs
pack_set -module-opt "-set-ENV GMXBIN=$(pack_get -prefix)/bin"
pack_set -module-opt "-set-ENV GMXLDLIB=$(pack_get -LD)"
pack_set -module-opt "-set-ENV GMXMAN=$(pack_get -prefix)/man"
pack_set -module-opt "-set-ENV GMXDATA=$(pack_get -prefix)/share/gromacs"

# Add auto source scripts (if users wishes to use these)
pack_set -module-opt "-set-ENV GMXRC_BASH=$(pack_get -prefix)/bin/GMXRC.bash"
pack_set -module-opt "-set-ENV GMXRC_CSH=$(pack_get -prefix)/bin/GMXRC.csh"
pack_set -module-opt "-set-ENV GMXRC_ZSH=$(pack_get -prefix)/bin/GMXRC.zsh"

done

# parallel
done

unset tmp_add_package
