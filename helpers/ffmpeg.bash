add_package --build generic \
    http://ffmpeg.org/releases/ffmpeg-2.7.1.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/ffmpeg

tmp=
# This ensures that we can encode x264 files (if header exists)
[ -e /usr/include/x264.h ] && tmp="$tmp --enable-libx264"

# Install commands that it should run
pack_set --command "./configure $tmp" \
    --command-flag "--prefix=$(pack_get --prefix)" \
    --command-flag "--disable-yasm --enable-x11grab" \
    --command-flag "--enable-gpl --enable-libpulse"

# Make commands
pack_set --command "make $(get_make_parallel)"
pack_set --command "make install"
