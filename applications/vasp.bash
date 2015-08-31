# Sadly, VASP only runs on Intel compiler...
for v in 5.3.3 5.3.5 ; do
if [[ $(vrs_cmp $v 5.3.5) -ge 0 ]]; then
    add_package \
	--directory vasp \
	--version $v \
	http://www.student.dtu.dk/~nicpa/packages/vasp-$v.tar
else
    add_package \
	--package vasp \
	--directory VASP \
	--version $v \
	http://www.student.dtu.dk/~nicpa/packages/VASP-$v.zip
fi
pack_set --module-requirement fftw-3

source applications/vasp-common-init.bash

# Install the correct FFT routine
pack_cmd "sed -i '$ a\
FFT3D   = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \\\\\n\
      $(pack_get --LD fftw-3)/libfftw3.a\n\
INCS    = -I$(pack_get --prefix fftw-3)/include' $file"

source applications/vasp-common-end.bash

done

