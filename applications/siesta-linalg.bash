# Generic routine for adding linear algebra
# libraries to siesta

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
LDFLAGS=$MKL_LIB $(list --LDFLAGS --Wlrpath $(pack_get --mod-req))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req))\n\
\n\
LIBS=\$(ADDLIB) -lmkl_scalapack_lp64 -lmkl_lapack95_lp64 -lmkl_blas95_lp64 -lmkl_blacs_openmpi_lp64 -mkl=sequential\n\
' arch.make"

elif $(is_c gnu) ; then

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	tmp="-llapack -lf77blas -lcblas -latlas"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	tmp="-llapack -lopenblas"
    else
	pack_set --module-requirement blas
	tmp="-llapack -lblas"
    fi
    pack_set --command "sed -i '1 a\
LDFLAGS=$(list --LDFLAGS --Wlrpath $(pack_get --mod-req))\n\
FPPFLAGS=$(list --INCDIRS $(pack_get --mod-req))\n\
\n\
LIBS=\$(ADDLIB) -lscalapack $tmp\n\
' arch.make"

else
    doerr "$(pack_get --package)" "Could not recognize the compiler: $(get_c)"

fi
