add_package http://www.student.dtu.dk/~nicpa/packages/dftb+_1.2.1.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/dftb+
pack_set --directory $(pack_get --directory)_src

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    cc=intel
    tmp=$(pack_get --alias)-$(pack_get --version).$cc

    cat <<EOF > $tmp
FC90 = $FC
FC90OPT = $FCFLAGS -openmp -mkl=parallel
CPP = cpp -traditional
CPPOPT = -DDEBUG=\$(DEBUG) # -DEXTERNALERFC
CPPPOST = \$(ROOT)/utils/fpp/fpp.sh general
LN = \$(FC90) 
LNOPT = -mkl=parallel -openmp
LIB_LAPACK = $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a
LIB_BLAS = $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a
LIBOPT = -L$MKL_PATH/lib/intel64
EOF
    
elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement lapack \
	--module-requirement atlas
    cc=gnu
    tmp=$(pack_get --alias)-$(pack_get --version).$cc
    
    cat <<EOF > $tmp
FC90 = $FC
FC90OPT = $FCFLAGS -fopenmp
CPP = cpp -traditional
CPPOPT = -DDEBUG=\$(DEBUG) # -DEXTERNALERFC
CPPPOST = \$(ROOT)/utils/fpp/fpp.sh general
LN = \$(FC90) 
LNOPT = -fopenmp
ATLASDIR = $(pack_get --install-prefix atlas)/lib
LIB_LAPACK = \$(ATLASDIR)/liblapack_atlas.a
LIB_BLAS = \$(ATLASDIR)/libf77blas.a \$(ATLASDIR)/libcblas.a \$(ATLASDIR)/libatlas.a
LIBOPT = -L\$(ATLASDIR)
EOF

else
    doerr dftb "Could not find compiler $(get_c)"

fi

# Copy over makefile
pack_set --command "mv $(pwd)/$tmp sysmakes/make.$cc"
pack_set --command "mv Makefile.user.template Makefile.user"
pack_set --command "sed -i -e 's/ARCH[[:space:]]*=.*/ARCH = $cc/g' Makefile.user"

# Install commands that it should run
pack_set --command "cd prg_dftb"
pack_set --command "make distclean"
pack_set --command "make $(get_make_parallel)"

# Make commands
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp _obj_$cc/dftb+ $(pack_get --install-prefix)/bin/"

pack_install
