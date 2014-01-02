for v in 1.8.0 ; do
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

# For future maybe this flag is important: NPY_SEPARATE_COMPILATION=0

file=site.cfg
pack_set --command "echo '#' > $file"

tmp_lib=$(list --prefix ':' --suffix '/lib' --loop-cmd 'pack_get --install-prefix' $(pack_get --module-requirement))
tmp_lib=${tmp_lib// /}
tmp_lib=${tmp_lib:1}:/usr/lib64:/lib64

tmp_inc=$(list --prefix ':' --suffix '/include' --loop-cmd 'pack_get --install-prefix' $(pack_get --module-requirement))
tmp_inc=${tmp_inc// /}
tmp_inc=${tmp_inc:1}

pack_set --command "sed -i '1 a\
[fftw]\n\
fftw3_libs   = fftw3\n\
[fftw3]\n\
fftw3_libs   = fftw3\n\
[amd]\n\
amd_libs = amd\n\
[umfpack]\n\
umfpack_libs = umfpack\n\
[DEFAULT]\n\
libraries = pthread,cholmod,ccolamd,camd,colamd,suitesparseconfig' $file"

# Check for Intel MKL or not
if $(is_c intel) ; then
    if [ -z "$MKL_PATH" ]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    pack_set --command "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_set --command "sed -i '$ a\
library_dirs = $tmp_lib:$MKL_PATH/lib/intel64:$INTEL_PATH/lib/intel64\n\
include_dirs = $tmp_inc:$MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n\
[mkl]\n\
library_dirs = $MKL_PATH/lib/intel64/:$INTEL_PATH/lib/intel64\n\
include_dirs = $MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n\
mkl_libs = mkl_rt,mkl_intel_lp64,mkl_gf_lp64,mkl_intel_thread,mkl_core,mkl_def\n\
lapack_libs = mkl_lapack95_lp64\n\
blas_libs = mkl_blas95_lp64' $file"

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
	pack_set --command "sed -i '$ a\
library_dirs = $(pack_get --install-prefix atlas)/lib:$tmp_lib\n\
include_dirs = $(pack_get --install-prefix atlas)/include:$tmp_inc\n\
[atlas_threads]\n\
atlas_threads_libs = ptf77blas,ptcblas,atlas\n\
[atlas]\n\
atlas_libs = f77blas,cblas,atlas\n\
[lapack]\n\
lapack_libs = lapack_atlas' $file" 

    # Correct the ATLAS understanding of the stuff
pack_set --command "sed -i -e \"s/atlas_threads_info(atlas_info):/atlas_threads_info(atlas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
pack_set --command "sed -i -e \"s/atlas_blas_threads_info(atlas_blas_info):/atlas_blas_threads_info(atlas_blas_info):\n\ \ \ \ section = 'atlas_threads'\n\ \ \ \ _lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
pack_set --command "sed -i -e \"s/_lib_lapack = \['lapack'\]/_lib_lapack = \['lapack_atlas'\]/g\" numpy/distutils/system_info.py"
pack_set --command "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:2}\]|g\" numpy/distutils/fcompiler/gnu.py"

    else
	pack_set --command "sed -i '$ a\
library_dirs = $(pack_get --install-prefix blas)/lib:$(pack_get --install-prefix lapack)/lib:$tmp_lib\n\
include_dirs = $(pack_get --install-prefix blas)/include:$(pack_get --install-prefix lapack)/include:$tmp_inc\n\
[lapack]\n\
lapack_libs = lapack' $file"

    fi

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
    doerr numpy "Have not been configured with recognized compiler"

fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
