for v in 3.2 4.0
do

if [[ $v == "3.2" ]]; then
add_package --package siesta \
    --version 3.2 \
    https://dl.dropbox.com/u/20267285/SIESTA-DOWNLOADS/siesta-3.2-pl-5.tgz
else
add_package --package siesta \
    --version $v \
    https://launchpad.net/siesta/$(str_version -1 $v).$(str_version -2 $v)/$v/+download/siesta-$v.tgz
fi

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/tbtrans

pack_set --module-requirement mpi --module-requirement netcdf-serial

if [[ $(vrs_cmp $v 3.1) -lt 0 ]]; then
    pack_set $(list --prefix '--host-reject ' zero ntch)
fi

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
FPPFLAGS:=\$(FPPFLAGS) -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
ADDLIB=-lnetcdff -lnetcdf\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
' arch.make"


source applications/siesta-linalg.bash

# Create install directory
pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# Add LTO in case of gcc-6.1 and version 4.1
if [[ $(vrs_cmp $v 4.1) -ge 0 ]]; then
if $(is_c gnu) ; then
    if [[ $(vrs_cmp $(get_c --version) 6.1.0) -ge 0 ]]; then
	pack_cmd "sed -i '$ a\
LIBS += -flto -fuse-linker-plugin \n\
FFLAGS += -flto\n'" arch.make
    fi
fi
fi


if [[ $(vrs_cmp $v 3.2) -gt 0 ]]; then
    source applications/siesta-speed.bash libSiestaXC.a siesta
else
    # Fix the long lines in the Makefile
    pack_cmd "sed -i -e \"s/>[[:space:]]*compinfo.F90.*/\
> tmp.F90\n\
\t\@awk '{if (length>80) { cur=78; \\\\\\\\\n\\\
\t\tprintf \\\"%s\&\\\\\\n\\\",substr(\\\$\\\$0,0,78); \\\\\\\\\n\\\
\t\twhile(length-cur>78) { cur=cur+76 ; \\\\\\\\\n\\\
\t\tprintf \\\"\&%s\&\\\\\\n\\\",substr(\\\$\\\$0,cur-76,76) \\\\\\\\\n\\\
\t\t} printf \\\"\&%s\\\\\\n\\\",substr(\\\$\\\$0,cur)} else { print \\\$\\\$0 }}' tmp.F90 > compinfo.F90/\" Makefile"
    
    source applications/siesta-speed.bash siesta
fi
pack_cmd "cp siesta $(pack_get --prefix)/bin/"

pack_cmd "make clean"

if [[ $(vrs_cmp $v 3.2) -gt 0 ]]; then
    source applications/siesta-speed.bash libSiestaXC.a transiesta
else
    source applications/siesta-speed.bash transiesta
fi
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
if [[ $(vrs_cmp $v 3.2) -le 0 ]]; then
    pack_cmd "cp fcbuild vibrator $(pack_get --prefix)/bin/"
else
    pack_cmd "cp fcbuild vibra $(pack_get --prefix)/bin/"
fi

pack_cmd "cd ../../"
pack_cmd "$FC $FCFLAGS vpsa2bin.f -o $(pack_get --prefix)/bin/vpsa2bin"
pack_cmd "$FC $FCFLAGS vpsb2asc.f -o $(pack_get --prefix)/bin/vpsb2asc"

# If the stable version of siesta has enabled the ESM module, 
# we compile that now
# Currently it works with 3.1
if [[ $(vrs_cmp $v 3.1) -eq 0 ]]; then

    # move back to head
    tmp=siesta-3.1_esm_v1.05
    pack_cmd "cd ../"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$tmp.tar.gz
    dwn_file http://www.student.dtu.dk/~nicpa/packages/$tmp.tar.gz $o
    pack_cmd "tar xfz $o"
    pack_cmd "patch -p1 < $tmp/esm_v1.05.diff"

    pack_cmd "cd Obj"
    pack_cmd "../Src/obj_setup.sh"
    pack_cmd "make dep"

    pack_cmd "make clean"

    source applications/siesta-speed.bash siesta
    pack_cmd "cp siesta $(pack_get --prefix)/bin/siesta_esm"
    
    pack_cmd "make clean"
    
    source applications/siesta-speed.bash transiesta
    pack_cmd "cp transiesta $(pack_get --prefix)/bin/transiesta_esm"

fi

done
