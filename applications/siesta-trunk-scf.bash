for v in 438 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-trunk-scf-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/hsx2hs

pack_set --module-requirement mpi --module-requirement netcdf
if [[ $(pack_installed metis) -eq 1 ]]; then
    pack_set --module-requirement metis
fi

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix the __FILE__ content in the classes
pack_cmd 'for f in Src/class* Src/fdf/utils.F90 Src/Fstack.T90 ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'

# Change to directory:
pack_cmd "cd Obj"

# Setup the compilation scheme
pack_cmd "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_cmd "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"

if [[ $(pack_installed metis) -eq 1 ]]; then
    pack_cmd "sed -i '1 a\
FPPFLAGS += -DON_DOMAIN_DECOMP\n\
ADDLIB += -lmetis' arch.make"
fi

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
FPPFLAGS += -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
NETCDF_INCFLAGS=$(list --INCDIRS netcdf-serial)\n\
NETCDF_LIBS=$(list --LD-rp netcdf-serial)\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lz\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' arch.make"

source applications/siesta-linalg.bash

pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# This should ensure a correct handling of the version info...
source applications/siesta-speed.bash libSiestaXC.a siesta
pack_cmd "cp siesta $(pack_get --prefix)/bin/"

pack_cmd "make clean"

source applications/siesta-speed.bash libSiestaXC.a transiesta
pack_cmd "cp transiesta $(pack_get --prefix)/bin/"

#pack_cmd "cd ../Util/TBTrans"
#pack_cmd "make"
#pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans_orig"

#pack_cmd "cd ../TBTrans_rep"
#pack_cmd "siesta_install -v scf --tbtrans"
#pack_cmd "make dep"
#pack_cmd "make"
#pack_cmd "cp tbtrans $(pack_get --prefix)/bin/tbtrans"

pack_cmd "cd ../Util/Bands"
pack_cmd "make all"
pack_cmd "cp new.gnubands $(pack_get --prefix)/bin/gnubands"
pack_cmd "cp eigfat2plot $(pack_get --prefix)/bin/eigfat2plot"

pack_cmd "cd ../Contrib/APostnikov"
pack_cmd "make all"
pack_cmd "cp *xsf fmpdos $(pack_get --prefix)/bin/"

#pack_cmd "cd ../../Denchar/Src"
#pack_cmd "make denchar"
#pack_cmd "cp denchar $(pack_get --prefix)/bin/"

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

# install the optimizer functions
pack_cmd "cd ../Optimizer"
pack_cmd "make swarm simplex"
pack_cmd "cp swarm simplex $(pack_get --prefix)/bin/"

# install grid-relevant utilities
# This requires that we change the libraries
pack_cmd "cd ../Grid"
files="grid2cdf cdf2xsf cdf2grid grid2val grid2cube grid_rotate cdf_fft cdf_diff grid_supercell"
files="grid2val grid2cube grid_rotate grid_supercell"
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
