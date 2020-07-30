v=0.12.0
add_package -package pyfftw -archive pyFFTW-$v.tar.gz \
	    https://github.com/pyFFTW/pyFFTW/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set $(list -prefix ' -module-requirement ' cython scipy fftw)

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages"

pack_cmd "HAVE_SINGLE=1 HAVE_DOUBLE=1 HAVE_OMP=1 PYFFTW_INCLUDE=$(pack_get -prefix fftw)/include PYFFTW_LIB_DIR=$(pack_get -prefix fftw)/lib $(get_parent_exec) setup.py build install --prefix=$(pack_get -prefix)"
