# Then install Atlas
add_package http://downloads.sourceforge.net/project/math-atlas/Stable/3.10.0/atlas3.10.0.tar.bz2

pack_set --directory ATLAS

pack_set --host-reject surt
pack_set --host-reject thul
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
tmp=$(get_hostname)
if [ "${tmp:0:4}" != "surt" ]; then
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


# It does depend on LAPACK, only for testing purposes!
module load $(get_default_modules)
module load $(pack_get --module-name lapack)
pack_install
module unload $(pack_get --module-name lapack)
module unload $(get_default_modules)
