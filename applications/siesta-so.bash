for v in 312 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-so-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/siesta

pack_set --module-requirement mpi --module-requirement netcdf

pack_set $(list -p '--host-reject ' zeroth ntch)

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"

pack_cmd "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90\n\
SIESTA_ARCH=x86_64-linux-Intel\n\
\n\
FPP=mpif90\n\
FPP_OUTPUT= \n\
FC=mpif90\n\
FC_SERIAL=$FC\n\
AR=$AR\n\
RANLIB=ranlib\n\
SYS=nag\n\
SP_KIND=4\n\
DP_KIND=8\n\
KINDS=\$(SP_KIND) \$(DP_KIND)\n\
\n\
FFLAGS=$FCFLAGS\n\
FPPFLAGS += -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
NETCDF_INCFLAGS=$(list --INCDIRS netcdf-serial)\n\
NETCDF_LIBS=$(list --LD-rp netcdf-serial)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' arch.make"

source applications/siesta-linalg.bash

pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# This should ensure a correct handling of the version info...
source applications/siesta-speed.bash siesta
pack_cmd "cp siesta $(pack_get --prefix)/bin/"

pack_cmd "make clean"

# We have not created a test for the check of already installed files...
source applications/siesta-speed.bash transiesta
pack_cmd "cp transiesta $(pack_get --prefix)/bin/"

pack_cmd "cd ../Util/Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf $(pack_get --prefix)/bin/"

pack_cmd "cd ../../WFS"
pack_cmd "make info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
pack_cmd "cp info_wfsx $(pack_get --prefix)/bin/"
pack_cmd "cp readwf $(pack_get --prefix)/bin/"
pack_cmd "cp readwfx $(pack_get --prefix)/bin/"
pack_cmd "cp wfs2wfsx $(pack_get --prefix)/bin/"
pack_cmd "cp wfsx2wfs $(pack_get --prefix)/bin/"

# install grid-relevant utilities
# This requires that we change the libraries
pack_cmd "cd ../Grid"
files="grid2cdf cdf2xsf cdf2grid grid2val grid2cube grid_rotate cdf_fft cdf_diff grid_supercell"
files="grid2val grid2cube"
pack_cmd "make $files"
pack_cmd "cp $files $(pack_get --prefix)/bin/"

pack_cmd "cd ../Vibra/Src"
pack_cmd "make"
pack_cmd "cp fcbuild vibrator $(pack_get --prefix)/bin/"

pack_cmd "cd ../../"

pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

# The atom program for creating the pseudos
pack_cmd "cd ../Pseudo/atom"
pack_cmd "make"
pack_cmd "cp atm $(pack_get --prefix)/bin/"

pack_cmd "chmod a+x $(pack_get --prefix)/bin/*"

done
