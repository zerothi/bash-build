for v in 2018.5 2019.1 ; do
add_package ftp://ftp.gromacs.org/pub/gromacs/gromacs-$v.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $BUILD_TOOLS

pack_set --module-opt "--lua-family gromacs"

pack_set --host-reject ntch --host-reject zerothi
if $(is_c gnu) ; then
    pack_set $(list -p '--host-reject ' n-62-25 n-62-26)
fi

pack_set --install-query $(pack_get --prefix)/bin/GMXRC

pack_set --module-requirement mpi --module-requirement fftw

tmp="-DGMX_MPI=ON -DCMAKE_INSTALL_PREFIX=$(pack_get --prefix)"
tmp="$tmp -DGMX_GPU=OFF"
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
tmp="$tmp -DGMX_PREFER_STATIC_LIBS=ON"
tmp="$tmp -DGMX_FFT_LIBRARY=fftw3"

# Allow 128 threads (default 32)
tmp="$tmp -DGMX_OPENMP_MAX_THREADS=128"
clib="$(list --prefix ':' --loop-cmd 'pack_get --LD' $(pack_get --mod-req))"
clib=${clib// /}
clib=${clib:1}

# configure the build...
pack_cmd "cmake .. $tmp -DCMAKE_PREFIX_PATH='$clib'"

# Make commands (cmake --build removes color)
pack_cmd "cmake --build ."
pack_cmd "cmake --build . --target install"

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
