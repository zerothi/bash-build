# Install grace
# apt-get lesstif2-dev or libmotif-dev
add_package ftp://plasma-gate.weizmann.ac.il/pub/grace/src/grace5/grace-5.1.25.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/fdf2fit

pack_set -module-opt "-lua-family grace"

pack_set -module-requirement netcdf-serial -build-mod-req fftw-2

# Install commands that it should run
pack_cmd "./configure" \
     "LDFLAGS='$(list -LD-rp $(pack_get -mod-req-path))'" \
     "LIBS='-lfftw -lnetcdff -lnetcdf'" \
     "CPPFLAGS='$(list -INCDIRS $(pack_get -mod-req-path)) $CPPFLAGS'" \
     "--enable-netcdf" \
     "--prefix=$(pack_get -prefix)" \
     "--enable-grace-home=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
