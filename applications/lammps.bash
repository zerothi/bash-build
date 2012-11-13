tmp=$(hostname)
#[ "${tmp:0:2}" != "n-" ] && return 0

add_package http://lammps.sandia.gov/tars/lammps.tar.gz

pack_set_file_version
pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --directory \
    lammps-"$(get_file_time %m%b%y $(get_build_path)/.archives/$(pack_get --archive $idx))"/src

pack_set --install-query $(pack_get --install-prefix)/bin/lmp_mpi

pack_set --module-requirement openmpi \
    --module-requirement fftw-serial-3


tmp_file=lammps-$(pack_get --version).make
cat <<EOF > $tmp_file
include MAKE/
SHELL=/bin/sh
CC =	     $MPICC
CCFLAGS =    $CFLAGS
SHFLAGS =	-fPIC
DEPFLAGS =	-M
LINK =		$MPICC
SIZE =		size
ARCHIVE =	$AR
ARFLAGS =	-rc
SHLIBFLAGS =	-shared
LMP_INC =	-DLAMMPS_GZIP
MPI_INC =       
MPI_PATH = 
MPI_LIB =      
FFT_INC =       -DFFT_FFTW3 -I$(pack_get --install-prefix fftw-serial-3)/include
FFT_PATH = 
FFT_LIB =	$(pack_get --install-prefix fftw-serial-3)/lib/libfftw3.a
JPG_INC =       
JPG_PATH = 	
JPG_LIB =
EOF

tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    cat <<EOF >> $tmp_file
LINKFLAGS =	-O
LIB =           -lpthread -mkl=sequential
EOF

elif [ "${tmp:0:3}" == "gnu" ]; then 
    cat <<EOF >> $tmp_file
LINKFLAGS =	-O
LIB =           -lpthread 
EOF

else
    doerror lammps "Could not recognize the compiler: $(get_c)"
fi


# Make commands
pack_set --command "cp $(pwd)/$tmp_file MAKE/Makefile.npa"
pack_set --command "make $(get_make_parallel) npa"
pack_set --command "make makelib"
pack_set --command "make -f Makefile.lib $(get_make_parallel) npa"
pack_set --command "asonteuhasonteuh"


pack_install