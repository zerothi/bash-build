# apt-get libpulse-dev libx264-* libx264-dev
add_package -build generic \
	    http://ffmpeg.org/releases/ffmpeg-4.1.3.tar.bz2

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/ffmpeg

tmp=
# This ensures that we can encode x264 files (if header exists)
[[ -e /usr/include/x264.h ]] && tmp="$tmp --enable-libx264"

# Install commands that it should run
pack_cmd "./configure $tmp" \
	 "--prefix=$(pack_get -prefix)" \
     --enable-shared \
	 --disable-yasm \
	 --enable-gpl --enable-libpulse

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
