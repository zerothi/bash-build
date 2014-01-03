# For completion of the version string...
# However, a first install should be fine...
# rm .archives/lammps.tar.gz
add_package http://lammps.sandia.gov/tars/lammps.tar.gz

pack_set_file_version
pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --host-reject ntch-l \
    --host-reject zeroth

pack_set --module-opt "--lua-family lammps"

pack_set --directory 'lammps-*'
pack_set --command 'cd src'

pack_set --install-query $(pack_get --install-prefix)/bin/lmp

pack_set --module-requirement openmpi \
    --module-requirement fftw-3

tmp=MAKE/Makefile.npa
pack_set --command "echo '# NPA-script' > $tmp"

pack_set --command "sed -i '1 a\
include ../MAKE/Makefile.linux\n\
SHELL=/bin/sh\n\
CC =         $MPICXX\n\
CCFLAGS =    $CFLAGS $(list --INCDIRS $(pack_get --module-paths-requirement))\n\
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
    pack_set --command "sed -i '$ a\
LINKFLAGS =  $MKL_LIB -mkl=sequential $(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
LIB =        -lstdc++ -lpthread -mkl=sequential' $tmp"

elif $(is_c gnu) ; then 
    pack_set --command "sed -i '$ a\
LINKFLAGS =  $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
LIB =        -lstdc++ -lpthread ' $tmp"

else
    doerror lammps "Could not recognize the compiler: $(get_c)"
fi

# Make commands
pack_set --command "make $(get_make_parallel) npa"
pack_set --command "make makelib"
pack_set --command "make -f Makefile.lib $(get_make_parallel) npa"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp lmp_npa $(pack_get --install-prefix)/bin/lmp"

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
