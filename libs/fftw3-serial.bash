add_package http://www.fftw.org/fftw-3.3.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE -s $BUILD_DIR

pack_set --alias fftw-serial
# The installation directory
pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --module-name $(pack_get --alias)/$(pack_get --version)/$(get_c)
pack_set --alias fftw-serial-3

pack_set --install-query $(pack_get --install-prefix)/lib/libfftw3.a

# Install commands that it should run
pack_set --command "../configure" \
    --command-flag "--prefix $(pack_get --install-prefix)"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make" \
    --command-flag "check" \
    --command-flag "install"

pack_install

