v=4.0.2
add_package --package siesta \
    --version $v \
    https://launchpad.net/siesta/4.0/$v/+download/siesta-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/tbtrans

pack_set --module-requirement mpi --module-requirement netcdf-serial

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix possible error in Src/Makefile
pack_cmd "sed -i -e 's/)-c/) -c/' Src/Makefile"

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"
pack_cmd "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90\n\
SIESTA_ARCH=x86_64-linux-$(get_hostname)\n\
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
FFLAGS=$FFLAGS\n\
FPPFLAGS:=\$(FPPFLAGS) -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF\n\
\n\
ARFLAGS_EXTRA=\n\
LIBS += $(list -LD-rp ++netcdf-serial) -lnetcdff -lnetcdf\n\
INCFLAGS += $(list -INCDIRS ++netcdf-serial)\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
.F.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.F90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$< \n\
.f.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
.c.o:\n\
\t\$(CC) -c \$(CFLAGS) \$(INCFLAGS) \$(FPPFLAGS) \$<\n\
.f90.o:\n\
\t\$(FC) -c \$(FFLAGS) \$(INCFLAGS) \$<\n\
\n' arch.make"


source applications/siesta-linalg.bash

# Create install directory
pack_cmd "mkdir -p $(pack_get --prefix)/bin"

source applications/siesta-speed.bash libSiestaXC.a siesta
pack_cmd "cp siesta $(pack_get --prefix)/bin/"

# Save the arch.make file
pack_cmd "cp arch.make $(pack_get --prefix)/arch.make"

pack_cmd "make clean"

source applications/siesta-speed.bash libSiestaXC.a transiesta
pack_cmd "cp transiesta $(pack_get --prefix)/bin/"

pack_cmd "cd ../Util/TBTrans"
pack_cmd "make"
pack_cmd "cp tbtrans $(pack_get --prefix)/bin/"

pack_cmd "cd ../WFS"
pack_cmd "make info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
pack_cmd "cp info_wfsx $(pack_get --prefix)/bin/"
pack_cmd "cp readwf $(pack_get --prefix)/bin/"
pack_cmd "cp readwfx $(pack_get --prefix)/bin/"
pack_cmd "cp wfs2wfsx $(pack_get --prefix)/bin/"
pack_cmd "cp wfsx2wfs $(pack_get --prefix)/bin/"

pack_cmd "cd ../HSX"
pack_cmd "make hs2hsx hsx2hs"
pack_cmd "cp hs2hsx $(pack_get --prefix)/bin/"
pack_cmd "cp hsx2hs $(pack_get --prefix)/bin/"

pack_cmd "cd ../Vibra/Src"
pack_cmd "make"
pack_cmd "cp fcbuild vibra $(pack_get --prefix)/bin/"

pack_cmd "cd ../../"
if [[ $(vrs_cmp $v 4.0.2) -lt 0 ]]; then
    pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
    pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"
fi
