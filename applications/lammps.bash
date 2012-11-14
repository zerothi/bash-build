tmp=$(hostname)
[ "${tmp:0:2}" != "n-" ] && return 0

add_package http://lammps.sandia.gov/tars/lammps.tar.gz

pack_set_file_version
pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --directory \
    lammps-"$(get_file_time %m%b%y $(get_build_path)/.archives/$(pack_get --archive $idx))"/src

pack_set --install-query $(pack_get --install-prefix)/bin/lmp

pack_set --module-requirement openmpi \
    --module-requirement fftw-3


tmp_file=lammps-$(pack_get --version).make
cat <<EOF > $tmp_file
include ../MAKE/Makefile.linux
SHELL=/bin/sh
CC =	     $MPICXX
CCFLAGS =    $CFLAGS $(list --INCDIRS --LDFLAGS --Wlrpath $(pack_get --module-requirement))
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
FFT_INC =       -DFFT_FFTW3 $(list --INCDIRS --LDFLAGS --Wlrpath fftw-3)
FFT_PATH = 
FFT_LIB =	-lfftw3
JPG_INC =       
JPG_PATH = 	
JPG_LIB =
EOF

tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    cat <<EOF >> $tmp_file
LINKFLAGS =	
LIB =           -lstdc++ -lpthread -mkl=sequential
EOF

elif [ "${tmp:0:3}" == "gnu" ]; then 
    cat <<EOF >> $tmp_file
LINKFLAGS =	
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
    --module-path $install_path/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name)
