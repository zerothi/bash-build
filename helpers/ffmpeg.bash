# apt-get libpulse-dev libx264-* libx264-dev
add_package -build generic \
	    https://www.ffmpeg.org/releases/ffmpeg-4.4.1.tar.xz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

# ensure this module also gets ld-library path added to the modules
pack_set -module-opt -ld-library-path

pack_set -install-query $(pack_get -prefix)/bin/ffmpeg

pack_set -mod-req openjpeg

tmp=
# This ensures that we can encode x264 files (if header exists)
[[ -e /usr/include/x264.h ]] && tmp="$tmp --enable-libx264"

# Install commands that it should run
pack_cmd "./configure $tmp" \
	 --prefix=$(pack_get -prefix) \
	 --enable-libopenjpeg \
	 --enable-shared \
	 --disable-yasm \
	 --enable-gpl --enable-libpulse

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
