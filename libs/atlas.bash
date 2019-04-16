# 3.11.34 (works)
for v in 3.11.41 3.10.3 ; do
tmp="--build generic"
if $(is_c gnu) ; then
    # If we use a later gnu version
    # we will prefer that
    tmp=
fi
if [[ $(vrs_cmp $v 3.10.3) -le 0 ]]; then
    add_package $tmp http://downloads.sourceforge.net/project/math-atlas/Stable/$v/atlas$v.tar.bz2
else
    add_package $tmp http://downloads.sourceforge.net/project/math-atlas/Developer%20%28unstable%29/$v/atlas$v.tar.bz2
fi

pack_set --directory ATLAS

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libatlas.a
pack_set --lib -lf77blas -lcblas -latlas
pack_set --lib[omp] -lf77blas -lcblas -latlas
pack_set --lib[pt] -lptf77blas -lptcblas -lptatlas

tmp=

# Prepare the make file
if [[ $(vrs_cmp $v 3.10.2) -le 0 ]]; then
    pack_cmd "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"
    tmp="$tmp --with-netlib-lapack-tarfile=$(build_get --archive-path)/$(pack_get --archive lapack) -Ss flapack $(pack_get --LD lapack)/liblapack.a"
else
    # Do not do threadcheck
    tmp="$tmp --cripple-atlas-performance"
    tmp="$tmp --with-netlib-lapack-tarfile=$(build_get --archive-path)/$(pack_get --archive lapack)"
fi

if [[ $(vrs_cmp $v 3.10.2) -eq 0 ]]; then
    tmp="$tmp --accel=0"
    pack_cmd "sed -i -e 's/int thrchk,/int thrchk=0,/' ../CONFIG/src/config.c"
fi

# Append the MHz
tmp="$tmp -m $(get_Hz --MHz)"

# Add fPIC for shared libraries
tmp="$tmp --shared -Fa alg '-fPIC'"
# Use 64 bit pointers
tmp="$tmp -b 64"
# Do not allow non-ieee breaks
tmp="$tmp -Si ieee 1"
# Tune lapack
tmp="$tmp -Si latune 1"
# Use parallel build
tmp="$tmp -Ss pmake '\$(MAKE) $(get_make_parallel)'"
# Use OpenMP for the threaded library
tmp="$tmp -Si omp 1 -F alg $FLAG_OMP"

# Configure command
# -Fa alg: append to all compilers -fPIC
pack_cmd "../configure" \
	 "--prefix=$(pack_get --prefix)" \
	 "--incdir=$(pack_get --prefix)/include" \
	 "--libdir=$(pack_get --LD)" \
	 "-t $NPROCS $tmp"

pack_cmd "make"
pack_cmd "make install"
pack_cmd "make check > atlas.test 2>&1"
pack_store atlas.test atlas.test.s
if ! $(is_host n-) ; then
    pack_cmd "make ptcheck > atlas.test 2>&1"
    pack_store atlas.test atlas.test.t
fi

# Move so that we can install correct lapack
pack_cmd "mv $(pack_get --LD)/liblapack.a $(pack_get --LD)/liblapack_atlas.a"

add_hidden_package lapack-atlas/$v
pack_set --prefix $(pack_get --prefix atlas)
pack_set --installed $_I_REQ
pack_set -mod-req atlas[$v]
# Denote the default libraries
# Note that this ATLAS compilation has lapack built-in
pack_set --lib -llapack_atlas $(pack_get --lib atlas[$v])
pack_set --lib[omp] -llapack_atlas $(pack_get --lib[omp] atlas[$v])
pack_set --lib[pt] -llapack_atlas $(pack_get --lib[pt] atlas[$v])
pack_set --lib[lapacke] ""

done

