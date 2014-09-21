v=4.2.1
add_package \
    --alias SS_config \
    --directory SuiteSparse_config \
    http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --library-path)/libsuitesparseconfig.a

mk=SuiteSparse_config.mk
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_set --command "echo 'CC = $CC' >> $mk"
pack_set --command "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_set --command "echo 'FFLAGS = $FFLAGS' >> $mk"


pack_set --command "make $(get_make_parallel)"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --library-path)/"
pack_set --command "mkdir -p $(pack_get --prefix)/include/"
pack_set --command "make INSTALL_LIB='$(pack_get --library-path)/'" \
    --command-flag "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
    --command-flag "install"



# We create the suitesparse_config makefile for all related packages!
# This needs to be runned every time, and thus we create a new package!
add_package \
    --package SS_config_make \
    http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set --directory SuiteSparse_config
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=SuiteSparse_config.mk
pack_set --command "echo 'CC = $CC' >> $mk"
pack_set --command "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_set --command "echo 'FFLAGS = $FFLAGS' >> $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_set --command "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix ss_config)/include/ \1|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_LIB\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"
pack_set --command "sed -i -e 's|^\(INSTALL_INCLUDE\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"

# Configure the SS make file for compliance with the rest of the installation.
pack_set --command "sed -i -e 's|^\(UMFPACK_CONFIG\)[[:space:]]*=.*|\1 = |' $mk"
pack_set --command "sed -i -e 's|^\(CHOLMOD_CONFIG\)[[:space:]]*=.*|\1 = -DNPARTITION |' $mk"

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lmkl_blas95_lp64|' $mk"
    pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -lmkl_lapack95_lp64|' $mk"

else

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas|' $mk"
	pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath atlas) -llapack|' $mk"
    elif [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath openblas) -lopenblas|' $mk"
	pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath openblas) -llapack|' $mk"
    else
	pack_set --module-requirement blas
	pack_set --command "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath blas) -lblas|' $mk"
	pack_set --command "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = $(list --LDFLAGS --Wlrpath blas) -llapack|' $mk"
    fi

fi

pack_set --command "cp SuiteSparse_config.mk ../"

