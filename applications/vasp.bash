for v in 5.3.3 ; do
add_package http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip

pack_set --version $(pack_get --version)-fftw3.3.2
pack_set --module-requirement fftw[3.3.2]

source applications/vasp-common-init.bash

# Install the correct FFT routine
cat <<EOF >> $tmp
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \
      $(pack_get --install-prefix fftw[3.3.2])/lib/libfftw3.a
INCS    = -I$(pack_get --install-prefix fftw[3.3.2])/include
EOF

source applications/vasp-common-end.bash

done