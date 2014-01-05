for v in 447 ; do

add_package http://www.student.dtu.dk/~nicpa/packages/siesta-trunk-scf-$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --install-prefix)/bin/hsx2hs

pack_set --module-requirement openmpi --module-requirement netcdf
if [ $(pack_installed metis) -eq 1 ]; then
    pack_set --module-requirement metis
fi

# Add the lua family
pack_set --module-opt "--lua-family siesta"

# Fix the __FILE__ content in the classes
pack_set --command 'for f in Src/class* ; do sed -i -e "s:__FILE__:\"$f\":g" $f ; done'
pack_set --command "sed -i -e 's:__FILE__:Fstack.T90:g' Src/Fstack.T90"

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


# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
LDFLAGS=$MKL_LIB $(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --module-paths-requirement))\n\
\n\
LIBS=\$(ADDLIB) -lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential\n\
' arch.make"

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	tmp="-llapack_atlas -lf77blas -lcblas -latlas"
    else
	pack_set --module-requirement blas --module-requirement lapack
	tmp="-llapack -lblas"
    fi
    pack_set --module-requirement scalapack
    pack_set --command "sed -i '1 a\
LDFLAGS=$(list --LDFLAGS --Wlrpath $(pack_get --module-paths-requirement))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --module-paths-requirement))\n\
\n\
LIBS=\$(ADDLIB) -lscalapack $tmp\n\
' arch.make"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

# This should ensure a correct handling of the version info...
pack_set --command "make version"

pack_set --command "siesta_install -v scf --siesta"
pack_set --command "make siesta"
pack_set --command "cp siesta $(pack_get --install-prefix)/bin/"

pack_set --command "make clean"

pack_set --command "make version"

# We have not created a test for the check of already installed files...
#pack_set --command "../Src/obj_setup.sh"
#pack_set --command "siesta_install --transiesta"
pack_set --command "make transiesta"
pack_set --command "cp transiesta $(pack_get --install-prefix)/bin/"

#pack_set --command "cd ../Util/TBTrans"
#pack_set --command "make"
#pack_set --command "cp tbtrans $(pack_get --install-prefix)/bin/tbtrans_orig"

#pack_set --command "cd ../TBTrans_rep"
#pack_set --command "siesta_install -v scf --tbtrans"
#pack_set --command "make dep"
#pack_set --command "make"
#pack_set --command "cp tbtrans $(pack_get --install-prefix)/bin/tbtrans"

pack_set --command "cd ../Util/Bands"
pack_set --command "make all"
pack_set --command "cp new.gnubands.o $(pack_get --install-prefix)/bin/gnubands"
pack_set --command "cp eigfat2plot.o $(pack_get --install-prefix)/bin/eigfat2plot"

pack_set --command "cd ../Contrib/APostnikov"
pack_set --command "make all"
pack_set --command "cp *xsf fmpdos $(pack_get --install-prefix)/bin/"

#pack_set --command "cd ../../Denchar/Src"
#pack_set --command "make denchar"
#pack_set --command "cp denchar $(pack_get --install-prefix)/bin/"

pack_set --command "cd ../../Eig2DOS"
pack_set --command "make"
pack_set --command "cp Eig2DOS $(pack_get --install-prefix)/bin/"

pack_set --command "cd ../WFS"
pack_set --command "make info_wfsx readwf readwfx wfs2wfsx wfsx2wfs"
pack_set --command "cp info_wfsx $(pack_get --install-prefix)/bin/"
pack_set --command "cp readwf $(pack_get --install-prefix)/bin/"
pack_set --command "cp readwfx $(pack_get --install-prefix)/bin/"
pack_set --command "cp wfs2wfsx $(pack_get --install-prefix)/bin/"
pack_set --command "cp wfsx2wfs $(pack_get --install-prefix)/bin/"

pack_set --command "cd ../HSX"
pack_set --command "make hs2hsx hsx2hs"
pack_set --command "cp hs2hsx $(pack_get --install-prefix)/bin/"
pack_set --command "cp hsx2hs $(pack_get --install-prefix)/bin/"

# Install the TS-analyzer
pack_set --command "cd ../TSAnalyzeSort"
pack_set --command "cp tsanalyzesort.py $(pack_get --install-prefix)/bin/"




# The atom program for creating the pseudos
pack_set --command "cd ../../Pseudo/atom"
pack_set --command "make"
pack_set --command "cp atm $(pack_get --install-prefix)/bin/"


pack_set --command "chmod a+x $(pack_get --install-prefix)/bin/*"

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)

done
