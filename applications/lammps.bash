# For completion of the version string...
# However, a first install should be fine...
# rm .archives/lammps.tar.gz
add_package http://lammps.sandia.gov/tars/lammps.tar.gz

pack_set_file_version
pack_set -s $MAKE_PARALLEL

pack_set --host-reject ntch --host-reject zeroth

pack_set --module-opt "--lua-family lammps"

pack_set --directory 'lammps-*'
pack_cmd 'cd src'

pack_set --install-query $(pack_get --prefix)/bin/lmp

pack_set --module-requirement mpi \
    --module-requirement fftw-3

tmp=MAKE/Makefile.npa
pack_cmd "echo '# NPA-script' > $tmp"

pack_cmd "sed -i '1 a\
include ../MAKE/Makefile.mpi\n\
SHELL=/bin/sh\n\
CC =         $MPICXX\n\
CCFLAGS =    $CFLAGS $(list --INCDIRS $(pack_get --mod-req-path))\n\
SHFLAGS =    -fPIC\n\
DEPFLAGS =   -M\n\
LINK =	     \$(CC)\n\
SIZE =	     size\n\
ARCHIVE =    $AR\n\
ARFLAGS =    -rc\n\
SHLIBFLAGS = -shared\n\
LMP_INC =    -DLAMMPS_GZIP\n\
MPI_INC =      \n\
MPI_PATH =     \n\
MPI_LIB =      \n\
FFT_INC =    -DFFT_FFTW3 $(list --INCDIRS fftw-3)\n\
FFT_PATH =     \n\
FFT_LIB =    -lfftw3\n\
JPG_INC =      \n\
JPG_PATH =     \n\
JPG_LIB = ' $tmp"


if $(is_c intel) ; then
    pack_cmd "sed -i '$ a\
LINKFLAGS =  $MKL_LIB -mkl=sequential $(list --LD-rp $(pack_get --mod-req-path))\n\
LIB =        -lstdc++ -lpthread -mkl=sequential' $tmp"

elif $(is_c gnu) ; then 
    pack_cmd "sed -i '$ a\
LINKFLAGS =  $(list --INCDIRS --LD-rp $(pack_get --mod-req-path))\n\
LIB =        -lstdc++ -lpthread ' $tmp"

else
    doerror lammps "Could not recognize the compiler: $(get_c)"
fi

# Make commands
pack_cmd "make $(get_make_parallel) npa"
pack_cmd "make mode=lib $(get_make_parallel) npa"
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cp lmp_npa $(pack_get --prefix)/bin/lmp"
# Copy the library over 
pack_cmd "mkdir -p $(pack_get --LD)"
pack_cmd "cp liblammps_npa.a $(pack_get --LD)/liblammps.a"
# Copy headers over 
pack_cmd "mkdir -p $(pack_get --prefix)/include"
pack_cmd "cp library.cpp library.h $(pack_get --prefix)/include/"
