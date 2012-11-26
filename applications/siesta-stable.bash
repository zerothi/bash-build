add_package http://icmab.cat/leem/siesta/CodeAccess/Code/siesta-3.1.tgz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/siesta

pack_set --module-requirement openmpi --module-requirement netcdf-serial

# Change to directory:
pack_set --directory $(pack_get --directory)/Obj

# Setup the compilation scheme
pack_set --command "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_set --command "touch arch.make"
pack_set --command "sed -i '1 a\
.SUFFIXES:\n\
.SUFFIXES: .f .F .o .a .f90 .F90\n\
SIESTA_ARCH=x86_64-linux-Intel\n\
\n\
FPP=$(pack_get --install-prefix openmpi)/bin/mpif90\n\
FPP_OUTPUT= \n\
FC=$(pack_get --install-prefix openmpi)/bin/mpif90\n\
FC_SERIAL=$FC\n\
AR=$AR\n\
RANLIB=ranlib\n\
SYS=nag\n\
SP_KIND=4\n\
DP_KIND=8\n\
KINDS=\$(SP_KIND) \$(DP_KIND)\n\
\n\
FFLAGS=$FCFLAGS\n\
FPPFLAGS=-DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF\n\
\n\
ARFLAGS_EXTRA=\n\
FCFLAGS_fixed_f=\n\
FCFLAGS_free_f90=\n\
FPPFLAGS_fixed_F=\n\
FPPFLAGS_free_F90=\n\
\n\
ADDLIB=\n\
\n\
MPI_INTERFACE=libmpi_f90.a\n\
MPI_INCLUDE=.\n\
\n\
.F.o:\n\
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_fixed_F)  $< \n\
.F90.o:\n\
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FPPFLAGS) $(FPPFLAGS_free_F90) $< \n\
.f.o:\n\
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_fixed_f)  $<\n\
.f90.o:\n\
	$(FC) -c $(FFLAGS) $(INCFLAGS) $(FCFLAGS_free_f90)  $<\n\
' arch.make"

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "sed -i '1 a\
LDFLAGS=-L$MKL_LIB -Wl,-rpath=$MKL_LIB $(pack_get --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
FPPFLAGS=\$(FPPFLAGS) $(pack_get --INCDIRS $(pack_get --module-requirement))\n\
\n\
LIBS=-lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_blacs_openmpi_lp64 -lnetcdf -lnetcdff\n\
' arch.make"

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    pack_set --module-requirement scalapack
    pack_set --command "sed -i '1 a\
LDFLAGS=$(pack_get --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
FPPFLAGS=\$(FPPFLAGS) $(pack_get --INCDIRS $(pack_get --module-requirement))\n\
\n\
LIBS=-lscalapack -llapack_atlas -lf77blas -lcblas -latlas -lnetcdf -lnetcdff\n\
' arch.make"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

pack_set --command "make siesta"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp siesta $(pack_get --install-prefix)/bin/"
pack_set --command "make clean"

pack_set --command "make transiesta"
pack_set --command "cp transiesta $(pack_get --install-prefix)/bin/"

pack_set --command "cd ../Util/TBTrans"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --install-prefix)/bin/"

pack_install