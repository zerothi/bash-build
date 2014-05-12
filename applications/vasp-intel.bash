# Sadly VASP only compiles with Intel
if $(is_c intel) ; then
for v in 5.3.3 5.3.5 ; do
if [ $(vrs_cmp $v 5.3.5) -ge 0 ]; then
    add_package \
	--directory vasp \
	http://www.student.dtu.dk/~nicpa/packages/vasp-$v.tar
else
    add_package \
	--package vasp \
	--directory VASP \
	http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip
fi
pack_set --version $v-fftwintel
pack_set --module-requirement fftw[intel]

source applications/vasp-common-init.bash

pack_set --command "sed -i '$ a\
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \\\\\n\
      $(pack_get --install-prefix fftw[intel])/lib/libfftw3xf.a\n\
INCS    = -I$(pack_get --install-prefix fftw[intel])/include' $file"

source applications/vasp-common-end.bash

done
fi

