# Then install Atlas
# old_v 3.10.0
for v in 3.10.1 ; do
add_package http://downloads.sourceforge.net/project/math-atlas/Stable/$v/atlas$v.tar.bz2

pack_set --directory ATLAS

pack_set $(list --prefix "--host-reject " surt muspell slid a0 b0 c0 d0 n0 p0 q0 g0)
pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/lib/libatlas.a

# Prepare the make file
pack_set --command "sed -i -e 's/ThrChk[[:space:]]*=[[:space:]]*1/ThrChk = 0/' ../CONFIG/src/config.c"

# Configure command
pack_set --command "../configure -Fa alg '-fPIC'" \
    --command-flag "-Ss flapack $(pack_get --prefix lapack)/lib/liblapack.a" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--incdir=$(pack_get --prefix)/include" \
    --command-flag "--libdir=$(pack_get --prefix)/lib" \
    --command-flag "--dylibs -m 2066.596 -t $NPROCS" \
    --command-flag "-b 64 -Si latune 1" \
    --command-flag "-Ss pmake '\$(MAKE) $(get_make_parallel)'"

# Make commands
pack_set --command "make"
if $(is_host surt muspell slid) ; then
    pack_set --command "make check ptcheck time"
fi
pack_set --command "make install"

# Create the ATLAS lapack
pack_set --command "mkdir -p tmp"
pack_set --command "cd tmp"
pack_set --command "$AR x ../lib/liblapack.a"
pack_set --command "cp $(pack_get --prefix lapack)/lib/liblapack.a ../liblapack.a"
pack_set --command "$AR r ../liblapack.a *.o"
pack_set --command "cd .."
pack_set --command "ranlib liblapack.a"
pack_set --command "cp liblapack.a $(pack_get --prefix)/lib/liblapack_atlas.a"

done
