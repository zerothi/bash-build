add_package https://sourceforge.net/projects/gracegtk/files/gracegtk-1.3.0.tgz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/gracegtk

pack_set -module-opt "-lua-family grace"

pack_set $(list -prefix '-mod-req ' netcdf-serial fftw gsl)

# Install commands that it should run
pack_cmd "./configure" \
     "LDFLAGS='$(list -LD-rp $(pack_get -mod-req-path))'" \
     "LIBS='-lfftw3 -lnetcdff -lnetcdf'" \
     "CPPFLAGS='$(list -INCDIRS $(pack_get -mod-req-path)) $CPPFLAGS'" \
     "--enable-netcdf"
     "--with-fftw3"
     "--prefix=$(pack_get -prefix)" \
     "--enable-grace-home=$(pack_get -prefix)"

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
