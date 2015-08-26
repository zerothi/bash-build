# Generic routine for adding linear algebra
# libraries to siesta

# Check for Intel MKL or not
siesta_la=mkl
if $(is_c intel) ; then

    pack_set --command "sed -i '1 a\
LDFLAGS=$MKL_LIB $(list --LD-rp $(pack_get --mod-req-path))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req-path))\n\
\n\
LIBS=\$(ADDLIB) -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64\n\
LIBS+= -lmkl_gf_lp64 -lmkl_core -lmkl_sequential\n\
' arch.make"

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack 
    tmp="-llapack"
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    siesta_la=$la
	    pack_set --module-requirement $la
	    [ "x$la" == "xatlas" ] && tmp="$tmp -lf77blas -lcblas"
	    [ "x$la" == "xacml" ] && tmp=""
	    tmp="$tmp -l$la"
	    pack_set --command "sed -i '1 a\
LDFLAGS=$(list --LD-rp $(pack_get --mod-req-path))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req-path))\n\
\n\
BLAS_LIBS=$tmp \n\
LIBS=\$(ADDLIB) -lscalapack \$(BLAS_LIBS)\n' arch.make"
	    break
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi

pack_set --command "sed -i '1 a\
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

pack_set --command "[ -e ../Src/atom.F ] && sed -i '$ a\
atom.o: atom.F\n\
\t\$(FC) -c -O1 \$(INCFLAGS) \$(FPPFLAGS) \$<\n' arch.make || echo NVM"
pack_set --command "[ -e ../Src/atom.f ] && sed -i '$ a\
atom.o: atom.f\n\
\t\$(FC) -c -O1 \$(INCFLAGS) \$<\n' arch.make || echo NVM"
