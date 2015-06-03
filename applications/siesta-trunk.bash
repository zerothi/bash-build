for v in 458 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-trunk-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement mpi --module-requirement netcdf
if [ $(pack_installed metis) -eq 1 ]; then
    pack_set --module-requirement metis
fi

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix __FILE__
pack_set --command 'f=Src/fdf/utils.F90 ; sed -i -e "s:__FILE__:\"$f\":g" $f'

# Change to directory:
pack_set --command "cd Obj"

# Setup the compilation scheme
pack_set --command "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"

if [ $(pack_installed metis) -eq 1 ]; then
    pack_set --command "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP\n\
ADDLIB += -lmetis' arch.make"
fi

pack_set --command "sed -i '1 a\
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
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5hl_fortran -lhdf5_fortran -lhdf5_hl -lhdf5 -lz\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
.F.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.F90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.f.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
.f90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
' arch.make"

source applications/siesta-linalg.bash

pack_set --command "mkdir -p $(pack_get --prefix)/bin"

# This should ensure a correct handling of the version info...
source applications/siesta-speed.bash libSiestaXC.a siesta
pack_set --command "cp siesta $(pack_get --prefix)/bin/"

pack_set --command "make clean"

source applications/siesta-speed.bash libSiestaXC.a transiesta
pack_set --command "cp transiesta $(pack_get --prefix)/bin/"

pack_set --command "cd ../Util/TBTrans"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --prefix)/bin/tbtrans_orig"

pack_set --command "cd ../TBTrans_rep"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --prefix)/bin/tbtrans"

pack_set --command "cd ../Contrib/APostnikov"
pack_set --command "make all"
pack_set --command "cp *xsf fmpdos $(pack_get --prefix)/bin/"

#pack_set --command "cd ../../Denchar/Src"
#pack_set --command "make denchar"
#pack_set --command "cp denchar $(pack_get --prefix)/bin/"

pack_set --command "cd ../../Eig2DOS"
pack_set --command "make"
pack_set --command "cp Eig2DOS $(pack_get --prefix)/bin/"

pack_set --command "cd ../WFS"
pack_set --command "make info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
pack_set --command "cp info_wfsx $(pack_get --prefix)/bin/"
pack_set --command "cp readwf $(pack_get --prefix)/bin/"
pack_set --command "cp readwfx $(pack_get --prefix)/bin/"
pack_set --command "cp wfs2wfsx $(pack_get --prefix)/bin/"
pack_set --command "cp wfsx2wfs $(pack_get --prefix)/bin/"

pack_set --command "cd ../HSX"
pack_set --command "make hs2hsx hsx2hs"
pack_set --command "cp hs2hsx $(pack_get --prefix)/bin/"
pack_set --command "cp hsx2hs $(pack_get --prefix)/bin/"

pack_set --command "cd ../Vibra/Src"
pack_set --command "make"
pack_set --command "cp fcbuild vibrator $(pack_get --prefix)/bin/"

pack_set --command "cd ../../"
pack_set --command "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_set --command "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"


# The atom program for creating the pseudos
pack_set --command "cd ../Pseudo/atom"
pack_set --command "make"
pack_set --command "cp atm $(pack_get --prefix)/bin/"


pack_set --command "chmod a+x $(pack_get --prefix)/bin/*"

done
