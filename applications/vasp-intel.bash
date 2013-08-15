for v in 5.3.3 ; do
add_package \
    --package vasp \
    --version $v-fftwintel \
    http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip

pack_set --module-requirement fftw[intel]

source applications/vasp-common-init.bash

pack_set --command "sed -i '$ a\
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \\\\\n\
      $(pack_get --install-prefix fftw[intel])/lib/libfftw3xf.a\n\
INCS    = -I$(pack_get --install-prefix fftw[intel])/include' $file"

source applications/vasp-common-end.bash

done
