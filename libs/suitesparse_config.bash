add_package http://www.cise.ufl.edu/research/sparse/UFconfig/SuiteSparse_config-4.0.2.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --alias SSconfig
pack_set --directory SuiteSparse_config
pack_set --install-query $(pack_get --install-prefix)/lib/libsuitesparseconfig.a


pack_set --command "make $(get_make_parallel)"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --install-prefix)/lib/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --install-prefix)/include/'" \
    --command-flag "install"

pack_install


# We create the suitesparse_config makefile for all related packages!
add_package http://www.cise.ufl.edu/research/sparse/UFconfig/SuiteSparse_config-4.0.2.tar.gz
pack_set --directory SuiteSparse_config
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --install-prefix SSconfig)/include/ \1|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_LIB\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_INCLUDE\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"

# For the moment leave out the CHOLMOD package
pack_set --command "sed -i -e 's|^\(UMFPACK_CONFIG\)[[:space:]]*=.*|\1 = -DNCHOLMOD|' $mk"

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lmkl_blas95_lp64|' $mk"
    pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -lmkl_lapack95_lp64|' $mk"

elif [ "${tmp:0:3}" == "gnu" ]; then
    # Add requirments when creating the module
    pack_set --module-requirement atlas

    pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lf77blas -lcblas|' $mk"
    pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -llapack_atlas|' $mk"

else
    doerr $(pack_get --package) "Has not been configured with $tmp compiler"

fi

pack_set --command "cp SuiteSparse_config.mk ../"

pack_install