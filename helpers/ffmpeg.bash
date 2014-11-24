add_package --build generic \
    http://ffmpeg.org/releases/ffmpeg-2.4.3.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

if $(is_host ntch zeroth) ; then
    echo "Continue" > /dev/null
else
    pack_set --host-reject $(get_hostname)
fi

pack_set --install-query $(pack_get --prefix)/bin/ffmpeg

# Install commands that it should run
pack_set --command "./configure" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--disable-yasm --enable-x11grab" \
    --command-flag "--enable-gpl --enable-libpulse"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
