# Sadly, VASP only runs on Intel compiler...
if $(is_c intel) ; then
for v in 5.3.5 ; do
add_package \
    --version $v-fftw$(pack_get --version fftw-3) \
    http://www.student.dtu.dk/~nicpa/packages/vasp-$v.tar

pack_set --module-requirement fftw-3

source applications/vasp-common-init.bash

# Install the correct FFT routine
pack_set --command "sed -i '$ a\
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \\\\\n\
      $(pack_get --install-prefix fftw-3)/lib/libfftw3.a\n\
INCS    = -I$(pack_get --install-prefix fftw-3)/include' $file"

source applications/vasp-common-end.bash

done
fi

