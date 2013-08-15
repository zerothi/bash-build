for v in 5.3.3 ; do
add_package \
    --package vasp \
    --version $v-fftw3.3.2 \
    http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip

pack_set --module-requirement fftw-3

source applications/vasp-common-init.bash

# Install the correct FFT routine
pack_set --command "sed -i '$ a\
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \\\\\n\
      $(pack_get --install-prefix fftw-3)/lib/libfftw3.a\n\
INCS    = -I$(pack_get --install-prefix fftw-3)/include' $file"

source applications/vasp-common-end.bash

done
