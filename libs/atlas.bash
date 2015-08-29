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

# Prepare the make file
pack_cmd "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"

tmp=
if [[ $(vrs_cmp $v 3.10.2) -gt 0 ]]; then
    tmp="-D c -DWALL --accel=0"
fi

# Configure command
# -Fa alg: append to all compilers -fPIC
pack_cmd "../configure -Fa alg '-fPIC'" \
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

done

