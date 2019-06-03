for par in serial mpi cuda
do

case $par in
    serial)
	tmp_add_package=""
	;;
    mpi)
	tmp_add_package="-package gromacs-mpi"
	;;
    cuda)
	tmp_add_package="-package gromacs-cuda -build cuda"
	# Check if we have build
	if $(build_exist cuda) ; then
	    noop
	else
	    msg_install --message "Skipping CUDA build for gromacs!"
	    continue
	fi
	;;
esac

for v in 2018.6 2019.2 ; do
add_package $tmp_add_package ftp://ftp.gromacs.org/pub/gromacs/gromacs-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $BUILD_TOOLS

pack_set --module-opt "--lua-family gromacs"

pack_set --install-query $(pack_get --prefix)/bin/GMXRC

pack_set --module-requirement fftw

tmp="-DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)"

case $par in
    mpi)
	pack_set --module-requirement mpi
	tmp="$tmp -DGMX_MPI=ON"
	;;
    cuda)
	tmp="$tmp -DGMX_GPU=ON -DCUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME"
	;;
esac

tmp="$tmp -DGMX_PREFER_STATIC_LIBS=ON"
tmp="$tmp -DGMX_FFT_LIBRARY=fftw3"

# Allow 128 threads (default 32)
tmp="$tmp -DGMX_OPENMP=ON"
tmp="$tmp -DGMX_OPENMP_MAX_THREADS=128"

if $(is_c intel) ; then
    # hopefully this should be enough
    tmp="$tmp -DGMX_LAPACK_USER='-mkl=parallel'"
    tmp="$tmp -DGMX_BLAS_USER='-mkl=parallel'"
    
elif $(is_c gnu) ; then
    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp_ld="$(list --LD-rp +$la)"
    tmp="$tmp -DGMX_LAPACK_USER='$(trim_spaces $tmp_ld) $(pack_get -lib $la)'"
    tmp="$tmp -DGMX_BLAS_USER='$(trim_spaces $tmp_ld) $(pack_get -lib $la) -lgfortran'"

else
    doerr $(pack_get --package) "Could not determine compiler: $(get_c)"
    
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

clib="$(list --prefix ':' --loop-cmd 'pack_get --LD' $(pack_get --mod-req))"
clib=${clib// /}
clib=${clib:1}

# configure the build...
pack_cmd "cmake .. $tmp -DCMAKE_PREFIX_PATH='$clib'"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_cmd "OMP_NUM_THREADS=$NPROCS make check > gromacs.test ; echo 'force'"
pack_store gromacs.test


# Add GROMACS envs
pack_set --module-opt "--set-ENV GMXBIN=$(pack_get --prefix)/bin"
pack_set --module-opt "--set-ENV GMXLDLIB=$(pack_get --LD)"
pack_set --module-opt "--set-ENV GMXMAN=$(pack_get --prefix)/man"
pack_set --module-opt "--set-ENV GMXDATA=$(pack_get --prefix)/share/gromacs"

# Add auto source scripts (if users wishes to use these)
pack_set --module-opt "--set-ENV GMXRC_BASH=$(pack_get --prefix)/bin/GMXRC.bash"
pack_set --module-opt "--set-ENV GMXRC_CSH=$(pack_get --prefix)/bin/GMXRC.csh"
pack_set --module-opt "--set-ENV GMXRC_ZSH=$(pack_get --prefix)/bin/GMXRC.zsh"

done

# parallel
done

unset tmp_add_package
