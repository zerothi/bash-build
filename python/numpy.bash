for v in 1.7.1 ; do
add_package http://downloads.sourceforge.net/project/numpy/NumPy/$v/numpy-$v.tar.gz

pack_set -s $IS_MODULE

if [ "x${pV:0:1}" == "x3" ]; then
    pack_set --install-query $(pack_get --install-prefix)/bin/f2py3
else
    pack_set --install-query $(pack_get --install-prefix)/bin/f2py
fi
pack_set --module-requirement $(get_parent) \
    --module-requirement fftw-3 --module-requirement umfpack
# Check for Intel MKL or not
if $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
    else
	pack_set --module-requirement blas
    fi
fi

cfg=$(pack_get --alias)-$(pack_get --version).site.cfg
tmp_lib=$(list --prefix ':' --suffix '/lib' --loop-cmd 'pack_get --install-prefix' $(pack_get --module-requirement))
tmp_lib=${tmp_lib// /}
tmp_lib=${tmp_lib:1}:/usr/lib64:/lib64

tmp_inc=$(list --prefix ':' --suffix '/include' --loop-cmd 'pack_get --install-prefix' $(pack_get --module-requirement))
tmp_inc=${tmp_inc// /}
tmp_inc=${tmp_inc:1}

cat << EOF > $cfg
[fftw]
fftw3_libs   = fftw3
[fftw3]
fftw3_libs   = fftw3
[amd]
amd_libs = amd
[umfpack]
umfpack_libs = umfpack
[DEFAULT]
libraries = pthread,cholmod,ccolamd,camd,colamd,suitesparseconfig
EOF

# Check for Intel MKL or not
if $(is_c intel) ; then
    if [ -z "$MKL_PATH" ]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $cfg
    cat << EOF >> $cfg
library_dirs = $tmp_lib:$MKL_PATH/lib/intel64:$INTEL_PATH/lib/intel64
include_dirs = $tmp_inc:$MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include
[mkl]
library_dirs = $MKL_PATH/lib/intel64/:$INTEL_PATH/lib/intel64
include_dirs = $MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include
mkl_libs = mkl_rt,mkl_intel_lp64,mkl_gf_lp64,mkl_intel_thread,mkl_core,mkl_def
lapack_libs = mkl_lapack95_lp64
blas_libs = mkl_blas95_lp64
EOF
    pack_set --command "mv $(pwd)/$cfg site.cfg"

    p_flags="$INTEL_LIB $MKL_LIB -mkl=parallel -fp-model strict -fomit-frame-pointer -I$(pack_get --install-prefix ss_config)/include"
    pack_set --command "sed -i -e \"s:cc_exe = 'icc:cc_exe = 'icc ${CFLAGS//-O3/-O2} $p_flags:g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e \"s/linker_exe=compiler,/linker_exe=compiler,archiver = ['$AR', '-cr'],/g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's|\(-shared\)|\1 -L${tmp_lib//:/ -L} -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=} $p_flags|g' numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's/\"ar\",/\"$AR\",/g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:opt = \[\]:opt = \[\"${FCFLAGS//-O3/-O2} $p_flags\"\]:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:F90:F77:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's|^\([[:space:]]*\)\(def get_flags_arch(self):.*\)|\1\2\n\1\1return \[\"${FCFLAGS//-O3/-O2} $p_flags\"\]|g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e \"/'linker_so'/s|\(.-shared.\)|\1,'-L${tmp_lib//:/ -L}','-Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=}','$p_flags'|g\" numpy/distutils/fcompiler/intel.py"
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 

elif $(is_c gnu) ; then
    if [ $(pack_installed atlas) -eq 1 ] ; then
	cat << EOF >> $cfg
library_dirs = $(pack_get --install-prefix atlas)/lib:$tmp_lib
include_dirs = $(pack_get --install-prefix atlas)/include:$tmp_inc
[atlas_threads]
atlas_threads_libs = ptf77blas,ptcblas,atlas
[atlas]
atlas_libs = f77blas,cblas,atlas
[lapack]
lapack_libs = lapack_atlas
EOF

pack_set --command "mv $(pwd)/$cfg site.cfg"

    # Correct the ATLAS understanding of the stuff
pack_set --command "sed -i -e \"s/atlas_threads_info(atlas_info):/atlas_threads_info(atlas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
pack_set --command "sed -i -e \"s/atlas_blas_threads_info(atlas_blas_info):/atlas_blas_threads_info(atlas_blas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
pack_set --command "sed -i -e \"s/_lib_lapack = \['lapack'\]/_lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
    # Add the flags to the EXTRAFLAGS for the GNU compiler
p_flags="${FCFLAGS// -/ } I$(pack_get --install-prefix ss_config)/include"
    # Remove the leading "-" for a flag
[ "${p_flags:0:1}" == "-" ] && p_flags="${p_flags:1}"
    # Create the list of flags in format ",'-<flag1>','-<flag2>',...,'-<flagN>'"
p_flags="$(list --prefix ,\'- --suffix \' ${p_flags//O3/O2} L${tmp_lib//:/ L} Wl,-rpath=${tmp_lib//:/ Wl,-rpath=})"
pack_set --command "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:2}\]|g\" numpy/distutils/fcompiler/gnu.py"
pack_set --command "sed -i -e 's|\(-Wall\)\(.\)|\1\2,\2-fPIC\2|g' numpy/distutils/fcompiler/gnu.py"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
    --command-flag "--compiler=unix" \
    --command-flag "--fcompiler=gnu95" 

    else
	cat << EOF >> $cfg
library_dirs = $(pack_get --install-prefix blas)/lib:$(pack_get --install-prefix lapack)/lib:$tmp_lib
include_dirs = $(pack_get --install-prefix blas)/include:$(pack_get --install-prefix lapack)/include:$tmp_inc
[lapack]
lapack_libs = lapack
EOF

pack_set --command "mv $(pwd)/$cfg site.cfg"

    # Add the flags to the EXTRAFLAGS for the GNU compiler
p_flags="${FCFLAGS// -/ } I$(pack_get --install-prefix ss_config)/include"
    # Remove the leading "-" for a flag
[ "${p_flags:0:1}" == "-" ] && p_flags="${p_flags:1}"
    # Create the list of flags in format ",'-<flag1>','-<flag2>',...,'-<flagN>'"
p_flags="$(list --prefix ,\'- --suffix \' ${p_flags//O3/O2} L${tmp_lib//:/ L} Wl,-rpath=${tmp_lib//:/ Wl,-rpath=})"
pack_set --command "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:2}\]|g\" numpy/distutils/fcompiler/gnu.py"
pack_set --command "sed -i -e 's|\(-Wall\)\(.\)|\1\2,\2-fPIC\2|g' numpy/distutils/fcompiler/gnu.py"
pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
    --command-flag "--compiler=unix" \
    --command-flag "--fcompiler=gnu95" 
    fi
else
    doerr numpy "Have not been configured with recognized compiler"

fi

# Install commands that it should run
# We need to unset the LDFLAGS as numpy will not be able to link to itself if set!
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"


done
