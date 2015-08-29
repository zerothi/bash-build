v=4.2.1
add_package \
    --alias SS_config \
    --directory SuiteSparse_config \
    http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuitesparseconfig.a

mk=SuiteSparse_config.mk
pack_cmd "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_cmd "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_cmd "echo 'CC = $CC' >> $mk"
pack_cmd "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_cmd "echo 'FFLAGS = $FFLAGS' >> $mk"


pack_cmd "make $(get_make_parallel)"
# Install commands that it should run
pack_cmd "mkdir -p $(pack_get --LD)/"
pack_cmd "mkdir -p $(pack_get --prefix)/include/"
pack_cmd "make INSTALL_LIB='$(pack_get --LD)/'" \
	 "INSTALL_INCLUDE='$(pack_get --prefix)/include/'" \
	 "install"



# We create the suitesparse_config makefile for all related packages!
# This needs to be runned every time, and thus we create a new package!
add_package \
    --package SS_config_make \
    http://www.cise.ufl.edu/research/sparse/SuiteSparse_config/SuiteSparse_config-$v.tar.gz

pack_set --directory SuiteSparse_config
pack_set --install-query /directory/does/not/exist

# Edit the mk file to comply with the standards
mk=SuiteSparse_config.mk
pack_cmd "echo 'CC = $CC' >> $mk"
pack_cmd "echo 'CFLAGS = $CFLAGS' >> $mk"
pack_cmd "echo 'FFLAGS = $FFLAGS' >> $mk"
pack_cmd "sed -i -e 's|^[[:space:]]*\(F77\)[[:space:]]*=.*|\1 = $F77|' $mk"
pack_cmd "sed -i -e 's|^[[:space:]]*\(F77FLAGS\)[[:space:]]*=.*|\1 = $FFLAGS|' $mk"
pack_cmd "sed -i -e 's|^[[:space:]]*CF[[:space:]]*=\(.*\)|CF = -I$(pack_get --prefix ss_config)/include/ \1|' $mk"
pack_cmd "sed -i -e 's|^\(INSTALL_LIB\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"
pack_cmd "sed -i -e 's|^\(INSTALL_INCLUDE\)[[:space:]]*=.*|\1 = /supply \1 on the make line|' $mk"

# Configure the SS make file for compliance with the rest of the installation.
pack_cmd "sed -i -e 's|^\(UMFPACK_CONFIG\)[[:space:]]*=.*|\1 = |' $mk"
pack_cmd "sed -i -e 's|^\(CHOLMOD_CONFIG\)[[:space:]]*=.*|\1 = -DNPARTITION |' $mk"

# Check for Intel MKL or not
if $(is_c intel) ; then
    pack_cmd "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = -lmkl_blas95_lp64|' $mk"
    pack_cmd "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = -lmkl_lapack95_lp64|' $mk"

else

    for la in $(choice linalg) ; do
	if [[ $(pack_installed $la) -eq 1 ]]; then
	    pack_set --module-requirement $la
	    tmp=
	    [[ "x$la" == "xatlas" ]] && \
		tmp="-lf77blas -lcblas"
	    tmp="$tmp -l$la"
	    break
	fi
    done

    pack_cmd "sed -i -e 's|^\(BLAS\)[[:space:]]*=.*|\1 = $(list --LD-rp $la) $tmp|' $mk"
    pack_cmd "sed -i -e 's|^\(LAPACK\)[[:space:]]*=.*|\1 = $(list --LD-rp $la) -llapack|' $mk"

fi

pack_cmd "cp SuiteSparse_config.mk ../"

