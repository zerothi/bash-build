v=0.13.1
add_package -package pyfftw -archive pyFFTW-$v.tar.gz \
	    https://github.com/pyFFTW/pyFFTW/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -build-mod-req cython
pack_set $(list -prefix ' -module-requirement ' scipy fftw)

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/pyfftw

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"

pack_cmd "HAVE_SINGLE=1 HAVE_DOUBLE=1 HAVE_OMP=1 PYFFTW_INCLUDE=$(pack_get -prefix fftw)/include PYFFTW_LIB_DIR=$(pack_get -prefix fftw)/lib $_pip_cmd . --prefix=$(pack_get -prefix)"
