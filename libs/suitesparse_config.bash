v=4.2.1
add_package http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --alias SS_config
pack_set --directory SuiteSparse_config
pack_set --install-query $(pack_get --install-prefix)/lib/libsuitesparseconfig.a

mk=SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_set --command "echo 'CC = $CC' >> $mk"
pack_set --command "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_set --command "echo 'FFLAGS = $FFLAGS' >> $mk"


pack_set --command "make $(get_make_parallel)"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install"



# We create the suitesparse_config makefile for all related packages!
# This needs to be runned every time, and thus we create a new package!
add_package http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set --alias SS_config_make
pack_set --directory SuiteSparse_config
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=SuiteSparse_config.mk
pack_set --command "echo 'CC = $CC' >> $mk"
pack_set --command "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_set --command "echo 'FFLAGS = $FFLAGS' >> $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix ss_config)/include/ \1|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_LIB\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_INCLUDE\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"

# Configure the SS make file for compliance with the rest of the installation.
pack_set --command "sed -i -e 's|^\(UMFPACK_CONFIG\)[[:space:]]*=.*|\1 = |' $mk"
pack_set --command "sed -i -e 's|^\(CHOLMOD_CONFIG\)[[:space:]]*=.*|\1 = -DNPARTITION |' $mk"

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lmkl_blas95_lp64|' $mk"
    pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -lmkl_lapack95_lp64|' $mk"

elif $(is_c gnu) ; then
    # Add requirments when creating the module
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas

	pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lf77blas -lcblas|' $mk"
	pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -llapack_atlas|' $mk"
    else
	pack_set --module-requirement lapack
	pack_set --module-requirement blas

	pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lblas|' $mk"
	pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -llapack|' $mk"
    fi
else
    doerr $(pack_get --package) "Has not been configured with $(get_c) compiler"

fi

pack_set --command "cp SuiteSparse_config.mk ../"

