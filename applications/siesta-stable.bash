for v in siesta-3.1 siesta-3.2 ; do
add_package http://icmab.cat/leem/siesta/CodeAccess/Code/$v.tgz
pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/bin/tbtrans

pack_set --module-requirement openmpi --module-requirement netcdf-serial

if [ $(vrs_cmp $(pack_get --version) "3.1") -lt 0 ]; then
    pack_set $(list --prefix '--host-reject ' zero ntch)
fi

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Change to directory:
pack_set --command "cd Obj"

# Setup the compilation scheme
pack_set --command "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"
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
FPPFLAGS:=\$(FPPFLAGS) -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
ADDLIB=-lnetcdff -lnetcdf\n\
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

# Fix the long lines in the Makefile
pack_set --command "sed -i -e \"s/>[[:space:]]*compinfo.F90.*/\
> tmp.F90\n\
\t\@awk '{if (length>80) { cur=78; \\\\\\\\\n\\\
\t\tprintf \\\"%s\&\\\\\\n\\\",substr(\\\$\\\$0,0,78); \\\\\\\\\n\\\
\t\twhile(length-cur>78) { cur=cur+76 ; \\\\\\\\\n\\\
\t\tprintf \\\"\&%s\&\\\\\\n\\\",substr(\\\$\\\$0,cur-76,76) \\\\\\\\\n\\\
\t\t} printf \\\"\&%s\\\\\\n\\\",substr(\\\$\\\$0,cur)} else { print \\\$\\\$0 }}' tmp.F90 > compinfo.F90/\" Makefile"

# Create install directory
pack_set --command "mkdir -p $(pack_get --prefix)/bin"

source applications/siesta-speed.bash siesta
pack_set --command "cp siesta $(pack_get --prefix)/bin/"

pack_set --command "make clean"

source applications/siesta-speed.bash transiesta
pack_set --command "cp transiesta $(pack_get --prefix)/bin/"

pack_set --command "cd ../Util/TBTrans"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --prefix)/bin/"

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

# If the stable version of siesta has enabled the ESM module, 
# we compile that now
# Currently it works with 3.1
if [ $(vrs_cmp $(pack_get --version) 3.1) -eq 0 ]; then

    # move back to head
    tmp=siesta-3.1_esm_v1.05
    pack_set --command "cd ../"
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$tmp.tar.gz
    mywget http://www.student.dtu.dk/~nicpa/packages/$tmp.tar.gz $o
    pack_set --command "tar xfz $o"
    pack_set --command "patch -p1 < $tmp/esm_v1.05.diff"

    pack_set --command "cd Obj"
    pack_set --command "../Src/obj_setup.sh"
    pack_set --command "make dep"

    pack_set --command "make clean"

    source applications/siesta-speed.bash siesta
    pack_set --command "cp siesta $(pack_get --prefix)/bin/siesta_esm"
    
    pack_set --command "make clean"
    
    source applications/siesta-speed.bash transiesta
    pack_set --command "cp transiesta $(pack_get --prefix)/bin/transiesta_esm"

fi

pack_install


create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --mod-req)) \
    -L $(pack_get --alias)

done
