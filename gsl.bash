# Install gsl
module purge
module load $(pack_get --module-name atlas)
add_package ftp://ftp.gnu.org/gnu/gsl/gsl-1.15.tar.gz

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/lib/libgsl.a

# Install commands that it should run
tmp=$(pack_get --install-prefix atlas)/lib/lib
pack_set --command "../configure" \
    --command-flag "LIBS='${tmp}f77blas.a ${tmp}cblas.a ${tmp}atlas.a'" \
    --command-flag "LDFLAGS='-L$(pack_get --install-prefix atlas)/lib'" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"

pack_install