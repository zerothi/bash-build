rm .archives/lammps.tar.gz
add_package http://lammps.sandia.gov/tars/lammps.tar.gz

pack_set_file_version
pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --host-reject ntch \
    --host-reject zeroth

pack_set --directory 'lammps-*'
pack_set --command 'cd src'

pack_set --install-query $(pack_get --install-prefix)/bin/lmp

pack_set --module-requirement openmpi \
    --module-requirement fftw-3


tmp_file=lammps-$(pack_get --version).make
cat <<EOF > $tmp_file
include ../MAKE/Makefile.linux
SHELL=/bin/sh
CC =	     $MPICXX
CCFLAGS =    $CFLAGS $(list --INCDIRS $(pack_get --module-requirement))
SHFLAGS =	-fPIC
DEPFLAGS =	-M
LINK =		\$(CC)
SIZE =		size
ARCHIVE =	$AR
ARFLAGS =	-rc
SHLIBFLAGS =	-shared
LMP_INC =	-DLAMMPS_GZIP
MPI_INC =       
MPI_PATH = 
MPI_LIB =      
FFT_INC =       -DFFT_FFTW3 $(list --INCDIRS fftw-3)
FFT_PATH = 
FFT_LIB =	-lfftw3
JPG_INC =       
JPG_PATH = 	
JPG_LIB =
EOF

if $(is_c intel) ; then
    cat <<EOF >> $tmp_file
LINKFLAGS =	$MKL_LIB -mkl=sequential $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))
LIB =           -lstdc++ -lpthread -mkl=sequential
EOF

elif $(is_c gnu) ; then 
    cat <<EOF >> $tmp_file
LINKFLAGS =	$(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-requirement))
LIB =           -lstdc++ -lpthread 
EOF

else
    doerror lammps "Could not recognize the compiler: $(get_c)"
fi


# Make commands
pack_set --command "cp $(pwd)/$tmp_file MAKE/Makefile.npa"
pack_set --command "make $(get_make_parallel) npa"
pack_set --command "make makelib"
pack_set --command "make -f Makefile.lib $(get_make_parallel) npa"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp lmp_npa $(pack_get --install-prefix)/bin/lmp"


pack_install

create_module \
    --module-path $(get_installation_path)/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(get_default_modules) $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
