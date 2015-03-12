# 3.11.28
tmp="--build generic-host"
if $(is_c gnu) ; then
    tmp=
fi
for v in 3.10.2 ; do
if [ $(vrs_cmp $v 3.10.2) -le 0 ]; then
    add_package $tmp http://downloads.sourceforge.net/project/math-atlas/Stable/$v/atlas$v.tar.bz2
else
    add_package $tmp http://www.student.dtu.dk/~nicpa/packages/atlas$v.tar.bz2
fi

pack_set --directory ATLAS

pack_set $(list --prefix "--host-reject " surt muspel slid hemera eris ponto n-62-17-44 n-62-26 n-62-25)
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libatlas.a

# Prepare the make file
pack_set --command "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"

tmp=
if [ $(vrs_cmp $v 3.10.2) -gt 0 ]; then
    tmp="-D c -DWALL --accel=0"
fi

# Configure command
# -Fa alg: append to all compilers -fPIC
pack_set --command "../configure -Fa alg '-fPIC'" \
    --command-flag "-Ss flapack $(pack_get --LD blas)/liblapack.a" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--incdir=$(pack_get --prefix)/include" \
    --command-flag "--libdir=$(pack_get --LD)" \
    --command-flag "-t $NPROCS --shared" \
    --command-flag "-b 64 -Si latune 1 $tmp" \
    --command-flag "-Ss pmake '\$(MAKE) $(get_make_parallel)'"

pack_set --command "make"
pack_set --command "make check > tmp.test 2>&1"
pack_set_mv_test tmp.test tmp.test.s
if ! $(is_host n-) ; then
    pack_set --command "make ptcheck > tmp.test 2>&1"
    pack_set_mv_test tmp.test tmp.test.t
fi
pack_set --command "make install"

# Move so that we can install correct lapack
pack_set --command "mv $(pack_get --LD)/liblapack.a $(pack_get --LD)/liblapack_atlas.a"

done

