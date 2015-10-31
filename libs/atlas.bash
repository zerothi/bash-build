# 3.11.34 (works)
for v in 3.10.2 ; do
tmp="--build generic-host"
if $(is_c gnu) ; then
    # If we use a later gnu version
    # we will prefer that
    tmp=
fi
if [[ $(vrs_cmp $v 3.10.2) -le 0 ]]; then
    add_package $tmp http://downloads.sourceforge.net/project/math-atlas/Stable/$v/atlas$v.tar.bz2
else
    add_package $tmp http://www.student.dtu.dk/~nicpa/packages/atlas$v.tar.bz2
fi

pack_set --directory ATLAS

pack_set $(list --prefix "--host-reject " n-62-17-44 n-62-26 n-62-25)
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libatlas.a
pack_set --lib -lf77blas -lcblas -latlas
pack_set --lib[omp] -lf77blas -lcblas -latlas
pack_set --lib[pt] -lptf77blas -lptcblas -lptatlas


# Prepare the make file
pack_cmd "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"

tmp=
if [[ $(vrs_cmp $v 3.10.2) -gt 0 ]]; then
    tmp="--accel=0"
    if $(is_host zero ntch) ; then
        tmp="$tmp -m 2800"
    fi
    pack_cmd "sed -i -e 's/int thrchk,/int thrchk=0,/' ../CONFIG/src/config.c"
fi

# Configure command
# -Fa alg: append to all compilers -fPIC
pack_cmd "../configure -Fa alg '-fPIC'" \
     "--with-netlib-lapack-tarfile=$(build_get --archive-path)/$(pack_get --archive lapack-blas)" \
	 "-Ss flapack $(pack_get --LD blas)/liblapack.a" \
	 "--prefix=$(pack_get --prefix)" \
	 "--incdir=$(pack_get --prefix)/include" \
	 "--libdir=$(pack_get --LD)" \
	 "-t $NPROCS --shared" \
	 "-b 64 -Si latune 1 $tmp" \
	 "-Ss pmake '\$(MAKE) $(get_make_parallel)'"

pack_cmd "make"
pack_cmd "make check > tmp.test 2>&1"
pack_set_mv_test tmp.test tmp.test.s
if ! $(is_host n-) ; then
    pack_cmd "make ptcheck > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.t
fi
pack_cmd "make install"

# Move so that we can install correct lapack
pack_cmd "mv $(pack_get --LD)/liblapack.a $(pack_get --LD)/liblapack_atlas.a"

add_hidden_package lapack-atlas/$v
pack_set --installed $_I_REQ
pack_set -mod-req atlas
# Denote the default libraries
# Note that this OpenBLAS compilation has lapack built-in
pack_set --lib -llapack_atlas $(pack_get --lib atlas[$v])
pack_set --lib[omp] -llapack_atlas $(pack_get --lib[omp] atlas[$v])
pack_set --lib[pt] -llapack_atlas $(pack_get --lib[pt] atlas[$v])

done

