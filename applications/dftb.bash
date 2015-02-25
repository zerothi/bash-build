for v in 1.2.2 ; do
add_package http://www.student.dtu.dk/~nicpa/packages/dftb+_$v.tar.gz

pack_set --host-reject ntch-l --host-reject zerothi

pack_set --module-opt "--lua-family dftb+"

pack_set --install-query $(pack_get --prefix)/bin/dftb+
pack_set --directory $(pack_get --directory)_src

# Check for Intel MKL or not
if $(is_c intel) ; then
    cc=intel
elif $(is_c gnu) ; then
    cc=gnu
fi
file=sysmakes/make.$cc
pack_set --command "echo '#' > $file"

if test -z "$FLAG_OMP" ; then
    doerr dftb "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
FC90 = $FC\n\
FC90OPT = $FCFLAGS $FLAG_OMP -mkl=parallel\n\
CPP = cpp -traditional\n\
CPPOPT = -DDEBUG=\$(DEBUG) # -DEXTERNALERFC\n\
CPPPOST = \$(ROOT)/utils/fpp/fpp.sh general\n\
LN = \$(FC90) \n\
LNOPT = -mkl=parallel $FLAG_OMP\n\
LIB_LAPACK = $MKL_LIB -lmkl_lapack95_lp64\n\
LIB_BLAS = $MKL_LIB -lmkl_blas95_lp64\n\
LIBOPT = $MKL_LIB' $file"
    
else
    pack_set --command "sed -i '1 a\
FC90 = $FC\n\
FC90OPT = $FCFLAGS $FLAG_OMP \n\
CPP = cpp -traditional\n\
CPPOPT = -DDEBUG=\$(DEBUG) # -DEXTERNALERFC\n\
CPPPOST = \$(ROOT)/utils/fpp/fpp.sh general\n\
LN = \$(FC90) \n\
LNOPT = $FLAG_OMP' $file"
    
    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ] ; then
	    pack_set --module-requirement $la
	    pack_set --command "sed -i '$ a\
LINALG_OPT = $(list --LDFLAGS --Wlrpath $la)\n\
LIB_LAPACK = \$(LINALG_OPT) -llapack\n\
LIBOPT = \$(LINALG_OPT)\n' $file"
	    if [ "x$la" == "xatlas" ]; then
		pack_set --command "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lf77blas -lcblas -latlas\n' $file"
	    elif [ "x$la" == "xopenblas" ]; then
		pack_set --command "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lopenblas_omp\n' $file"
	    elif [ "x$la" == "xblas" ]; then
		pack_set --command "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lblas\n' $file"
	    fi
	    break
	fi
    done

fi

pack_set --command "mv Makefile.user.template Makefile.user"
pack_set --command "sed -i -e 's/ARCH[[:space:]]*=.*/ARCH = $cc/g' Makefile.user"

# Install commands that it should run
pack_set --command "cd prg_dftb"
pack_set --command "make distclean"
pack_set --command "make $(get_make_parallel)"

# Make commands
pack_set --command "mkdir -p $(pack_get --prefix)/bin"
pack_set --command "cp _obj_$cc/dftb+ $(pack_get --prefix)/bin/"

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
