tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://downloads.sourceforge.net/project/numpy/NumPy/1.6.2/numpy-1.6.2.tar.gz

pack_set -s $IS_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name \
    $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/f2py
pack_set --module-requirement $(get_parent)

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    tmp=$(pack_get --alias)-$(pack_get --version).site.cfg
    if [ -z "$MKL_PATH" ]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    cat << EOF > $tmp
[mkl]
library_dirs = $MKL_PATH/lib/intel64/
include_dirs = $MKL_PATH/include/intel64/lp64:$MKL_PATH/include
mkl_libs = mkl_rt, mkl_core, mkl_def, mkl_intel_lp64, mkl_intel_thread, mkl_mc 
lapack_libs = mkl_lapack95_lp64
EOF

    pack_set --command "cp $(pwd)/$tmp site.cfg"
    pack_set --command "rm $(pwd)/$tmp"
    tmp="-static -mkl -openmp -fp-model strict -fomit-frame-pointer"
    pack_set --command "sed -i -e \"s/cc_exe = 'icc/cc_exe = 'icc ${CFLAGS//-O3/-O2} $tmp/g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e \"s/linker_exe=compiler,/linker_exe=compiler,archiver = ['$AR', '-cr'],/g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's/\"ar\",/\"xiar\",/g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's/opt = [[]]/opt = [\"${FCFLAGS//-O3/-O2} $tmp\"]/g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 

elif [ "${tmp:0:3}" == "gnu" ]; then
    # Add requirments when creating the module
    pack_set --module-requirement lapack \
	--module-requirement atlas

    tmp=$(pack_get --alias)-$(pack_get --version).site.cfg
    cat << EOF > $tmp
[DEFAULT]
library_dirs = $(pack_get --install-prefix atlas)/lib
include_dirs = $(pack_get --install-prefix atlas)/include
search_static_first = 1
[blas]
blas_libs = f77blas
[lapack]
lapack_libs = lapack_atlas
[atlas]
atlas_libs         = f77blas,cblas,atlas
atlas_blas_libs    = f77blas,cblas
[atlas_threads]
atlas_threads_libs = ptf77blas,ptcblas,atlas
EOF
    pack_set --command "cp $(pwd)/$tmp site.cfg"
    pack_set --command "rm $(pwd)/$tmp"
    # Correct the ATLAS understanding of the stuff
    pack_set --command "sed -i -e \"s/atlas_threads_info(atlas_info):/atlas_threads_info(atlas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = ['lapack_atlas']/g\" numpy/distutils/system_info.py"
    pack_set --command "sed -i -e \"s/atlas_blas_threads_info(atlas_blas_info):/atlas_blas_threads_info(atlas_blas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = ['lapack_atlas']/g\" numpy/distutils/system_info.py"
    pack_set --command "sed -i -e \"s/_lib_lapack = \['lapack'\]/_lib_lapack = ['lapack_atlas']/g\" numpy/distutils/system_info.py"
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--compiler=unix" \
	--command-flag "--fcompiler=gnu95" 

else
    doerr numpy "Has not been configured with $tmp compiler"
fi


# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install

