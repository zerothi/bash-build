v=2.83.1
add_package -version $v -package blender \
	    https://mirrors.dotsrc.org/blender/blender-release/Blender${v}/blender-${v}.tar.xz

pack_set -s $MAKE_PARALLEL -s $BUILD_DIR
pack_set -build-mod-req build-tools

pack_set -module-opt "--lua-family blender"

if [[ $(vrs_cmp $pV 3.7) -lt 0 ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -mod-req ffmpeg -mod-req openimageio
pack_set -mod-req openjpeg
pack_set -mod-req python
pack_set -mod-req numpy

pack_set -install-query $(pack_get -prefix)/bin/blender

pack_cmd "unset LDFLAGS"
pack_cmd "unset CFLAGS"
pack_cmd "unset CPPFLAGS"
pack_cmd cmake -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix) \
	 -DWITH_BLENDER=on \
	 -DWITH_INSTALL_PORTABLE=off \
	 -DCMAKE_BUILD_TYPE="Release" \
	 -DWITH_CODEC_FFMPEG=on \
	 -DWITH_FFMPEG=on \
	 -DFFMPEG=$(pack_get -prefix ffmpeg) \
	 -DFFMPEG_INCLUDE_DIRS=$(pack_get -prefix ffmpeg)/include \
	 -DFFMPEG_LIBPATH=$(pack_get -prefix ffmpeg)/lib \
	 -DWITH_FFTW3=on \
	 -DFFTW3_LIBRARY=$(pack_get -prefix fftw) \
	 -DFFTW3_INCLUDE_DIR=$(pack_get -prefix fftw)/include \
	 -DWITH_BOOST=on \
	 -DBOOST_INCLUDE_DIR=$(pack_get -prefix boost)/include \
	 -DWITH_IMAGE_OPENJPEG=on \
	 -DWITH_PYTHON_INSTALL=off \
	 -DWITH_PYTHON=on \
	 -DWITH_PYTHON_MODULE=on \
	 -DPYTHON_NUMPY_PATH=$(python3 -c "import numpy as np ; print(np.__file__.split('site-packages')[0] + '/site-packages')") \
	 -DPYTHON_INCLUDE_DIR=$(pack_get -prefix python)/include/python3.7m \
	 -DPYTHON_SITE_PACKAGES=$(pack_get -prefix)/lib/python \
	 -DWITH_X11=on -DWITH_OPENMP=on \
	 -DWITH_OPENCOLLADA=off -DWITH_SDL=off -DWITH_OPENAL=off \
	 -DWITH_CYCLES=on \
	 -DWITH_CYCLES_DEVICE_CUDA=off \
	 -DWITH_CYCLES_DEVICE_OPENCL=off \
	 -DWITH_CYCLES_NATIVE_ONLY=on \
	 -DOPENEXR_ROOT_DIR=$(pack_get -prefix openexr) \
	 -DWITH_IMAGE_OPENEXR=on \
	 -DWITH_OPENIMAGEIO=on \
	 -DOPENIMAGEIO_LIBRARY=$(pack_get -prefix openimageio)/lib/libOpenImageIO.so \
	 -DOPENIMAGEIO_INCLUDE_DIR=$(pack_get -prefix openimageio)/include \
	 -DWITH_AUDASPACE=off \
	 -DWITH_MOD_FLUID=off \
	 -DWITH_LLVM=off \
	 -DWITH_XR_OPENXR=off \
	 -DWITH_TBB=off \
	 ..

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"