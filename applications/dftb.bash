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
pack_cmd "echo '#' > $file"

if [[ -z "$FLAG_OMP" ]]; then
    doerr dftb "Can not find the OpenMP flag (set FLAG_OMP in source)"
fi

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i '1 a\
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
    pack_cmd "sed -i '1 a\
FC90 = $FC\n\
FC90OPT = $FCFLAGS $FLAG_OMP \n\
CPP = cpp -traditional\n\
CPPOPT = -DDEBUG=\$(DEBUG) # -DEXTERNALERFC\n\
CPPPOST = \$(ROOT)/utils/fpp/fpp.sh general\n\
LN = \$(FC90) \n\
LNOPT = $FLAG_OMP' $file"
    
    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    pack_cmd "sed -i '$ a\
LINALG_OPT = $(list --LD-rp $la)\n\
LIB_LAPACK = \$(LINALG_OPT) -llapack\n\
LIBOPT = \$(LINALG_OPT)\n' $file"
	    case $la in
		atlas)
		    pack_cmd "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lf77blas -lcblas -latlas\n' $file"
		    ;;
		openblas)
		    pack_cmd "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lopenblas_omp\n' $file"
		    ;;
		blas)
		    pack_cmd "sed -i '$ a\
LIB_BLAS   = \$(LINALG_OPT) -lblas\n' $file"
		    ;;
	    esac
	    break
	fi
    done

fi

pack_cmd "mv Makefile.user.template Makefile.user"
pack_cmd "sed -i -e 's/ARCH[[:space:]]*=.*/ARCH = $cc/g' Makefile.user"

# Install commands that it should run
pack_cmd "cd prg_dftb"
pack_cmd "make distclean"
pack_cmd "make $(get_make_parallel)"

# Make commands
pack_cmd "mkdir -p $(pack_get --prefix)/bin"
pack_cmd "cp _obj_$cc/dftb+ $(pack_get --prefix)/bin/"

done
