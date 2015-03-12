# Generic routine for adding linear algebra
# libraries to siesta

# Check for Intel MKL or not
siesta_la=mkl
if $(is_c intel) ; then

    pack_set --command "sed -i '1 a\
LDFLAGS=$MKL_LIB $(list --LDFLAGS --Wlrpath $(pack_get --mod-req-path))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req-path))\n\
\n\
LIBS=\$(ADDLIB) -lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential\n\
' arch.make"

elif $(is_c gnu) ; then

    tmp="-llapack"
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    siesta_la=$la
	    pack_set --module-requirement $la
	    [ "x$la" == "xatlas" ] && \
		tmp="$tmp -lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    pack_set --command "sed -i '1 a\
LDFLAGS=$(list --LDFLAGS --Wlrpath $(pack_get --mod-req-path))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req-path))\n\
\n\
BLAS_LIBS=$tmp \n\
LIBS=\$(ADDLIB) -lscalapack \$(BLAS_LIBS)\n\
' arch.make"
	    break
	fi
    done

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
