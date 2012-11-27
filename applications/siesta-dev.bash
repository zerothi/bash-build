add_package http://icmab.cat/leem/siesta/CodeAccess/Code/siesta-trunk-424.tgz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --install-prefix)/bin/tbtrans

pack_set --module-requirement openmpi --module-requirement netcdf

# Change to directory:
pack_set --directory $(pack_get --directory)/Obj

# Setup the compilation scheme
pack_set --command "../Src/obj_setup.sh"

# Prepare the compilation arch.make
pack_set --command "echo '# Compilation $(pack_get --version) on $(get_c)' > arch.make"
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
FFLAGS=${FCFLAGS//-fno-second-underscore/}\n\
FPPFLAGS:=\$(FPPFLAGS) -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DCDF -DCDF4\n\
\n\
ARFLAGS_EXTRA=\n\
\n\
ADDLIB=-lnetcdff -lnetcdf -lpnetcdf -lhdf5_hl -lhdf5 -lhdf5hl_fortran -lhdf5_fortran -lz\n\
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
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "sed -i '1 a\
LDFLAGS=$MKL_LIB $(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --module-requirement))\n\
\n\
LIBS=\$(ADDLIB) -lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential\n\
' arch.make"

elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    pack_set --module-requirement scalapack
    pack_set --command "sed -i '1 a\
LDFLAGS=$(list --LDFLAGS --Wlrpath $(pack_get --module-requirement))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --module-requirement))\n\
\n\
LIBS=\$(ADDLIB) -lscalapack -llapack_atlas -lf77blas -lcblas -latlas\n\
' arch.make"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi


# Correct an error for the GNU compiler:
pack_set --command "sed -i -e 's/c(1:[A-Za-z]*)[[:space:]]*=>/c =>/g' ../Src/m_ts_contour.f90"


pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

pack_set --command "make libmpi_f90.a"
pack_set --command "make libfdf.a"
pack_set --command "make libxmlparser.a"
pack_set --command "make libSiestaXC.a ; echo 'Maybe existing'"
pack_set --command "make FoX/.FoX"
pack_set --command "make $(get_make_parallel) siesta"
pack_set --command "cp siesta $(pack_get --install-prefix)/bin/"

pack_set --command "make clean"

pack_set --command "make libmpi_f90.a"
pack_set --command "make libfdf.a"
pack_set --command "make libxmlparser.a"
pack_set --command "make libSiestaXC.a ; echo 'Maybe existing'"
pack_set --command "make FoX/.FoX"
pack_set --command "make $(get_make_parallel) transiesta"
pack_set --command "cp transiesta $(pack_get --install-prefix)/bin/"

pack_set --command "cd ../Util/TBTrans"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --install-prefix)/bin/tbtrans_orig"

pack_set --command "cd ../TBTrans_rep"
pack_set --command "siesta_install --tbtrans"
pack_set --command "make dep"
pack_set --command "make"
pack_set --command "cp tbtrans $(pack_get --install-prefix)/bin/tbtrans"

pack_install


create_module \
    --module-path $install_path/modules-npa-apps \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" $(list --prefix '-L ' $(get_default_modules)) \
    $(list --prefix '-L ' --loop-cmd 'pack_get --module-name' $(pack_get --module-requirement)) \
    -L $(pack_get --module-name)

