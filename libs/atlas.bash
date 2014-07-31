# 3.11.28
for v in 3.10.2 ; do
if [ $(vrs_cmp $v 3.10.2) -le 0 ]; then
    add_package http://downloads.sourceforge.net/project/math-atlas/Stable/$v/atlas$v.tar.bz2
else
    add_package http://www.student.dtu.dk/~nicpa/packages/atlas$v.tar.bz2
fi

pack_set --directory ATLAS

pack_set $(list --prefix "--host-reject " surt muspel slid)
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libatlas.a

# Prepare the make file
pack_set --command "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"

tmp=
if [ $(vrs_cmp $v 3.10.2) -gt 0 ]; then
    tmp="-D c -DWALL --accel=0"
fi

# Configure command
# -Fa alg: append to all compilers -fPIC
pack_set --command "../configure -Fa alg '-fPIC'" \
    --command-flag "-Ss flapack $(pack_get --prefix blas)/lib/liblapack.a" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--incdir=$(pack_get --prefix)/include" \
    --command-flag "--libdir=$(pack_get --prefix)/lib" \
    --command-flag "-t $NPROCS --shared" \
    --command-flag "-b 64 -Si latune 1 $tmp" \
    --command-flag "-Ss pmake '\$(MAKE) $(get_make_parallel)'"

pack_set --command "make"
pack_set --command "make check > tmp.test 2>&1"
pack_set_mv_test tmp.test tmp.test.s
pack_set --command "make ptcheck > tmp.test 2>&1"
pack_set_mv_test tmp.test tmp.test.t

pack_set --command "make install"

pack_set --command "cp lib/liblapack.a $(pack_get --prefix)/lib/liblapack_atlas.a"

done

