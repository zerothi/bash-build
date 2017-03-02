for v in 465 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-mattias-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/tbtrans

pack_set --module-requirement mpi --module-requirement netcdf

pack_set --host-reject zero --host-reject ntch

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix __FILE__
pack_cmd 'f=Src/fdf/utils.F90 ; sed -i -e "s:__FILE__:\"$f\":g" $f'

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
FFLAGS=$FCFLAGS\n\
FPPFLAGS:=\$(FPPFLAGS) -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' arch.make"

source applications/siesta-linalg.bash

# Correct an error for the GNU compiler:
pack_cmd "sed -i -e 's/c(1:[A-Za-z]*)[[:space:]]*=>/c =>/g' ../Src/m_ts_contour.f90"


pack_cmd "mkdir -p $(pack_get --prefix)/bin"

pack_cmd "siesta_install --siesta"
source applications/siesta-speed.bash libSiestaXC.a siesta
pack_cmd "cp siesta $(pack_get --prefix)/bin/"

pack_cmd "make clean"

# We have not created a test for the check of already installed files...
#pack_cmd "../Src/obj_setup.sh"
#pack_cmd "siesta_install --transiesta"
source applications/siesta-speed.bash libSiestaXC.a transiesta
pack_cmd "cp transiesta $(pack_get --prefix)/bin/"

pack_cmd "cd ../Util/TBTrans"
pack_cmd "make"
pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans_orig"

pack_cmd "cd ../TBTrans_rep"
pack_cmd "siesta_install --tbtrans"
pack_cmd "make dep"
pack_cmd "make"
pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans"

pack_cmd "cd ../Bands"
pack_cmd "make all"
pack_cmd "cp new.gnubands $(pack_get --prefix)/bin/gnubands"
pack_cmd "chmod a+x $(pack_get --prefix)/bin/gnubands"
pack_cmd "cp eigfat2plot $(pack_get --prefix)/bin/eigfat2plot"
pack_cmd "chmod a+x $(pack_get --prefix)/bin/eigfat2plot"

pack_cmd "cd ../Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf fmpdos $(pack_get --prefix)/bin/"

pack_cmd "cd ../../Denchar/Src"
pack_cmd "make denchar"
pack_cmd "cp denchar $(pack_get --prefix)/bin/"

pack_cmd "cd ../../Eig2DOS"
pack_cmd "make"
pack_cmd "cp Eig2DOS $(pack_get --prefix)/bin/"

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
pack_cmd "cp fcbuild vibrator $(pack_get --prefix)/bin/"

pack_cmd "cd ../../"
pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

done
