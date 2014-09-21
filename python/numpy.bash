for v in 1.8.2 ; do
add_package http://downloads.sourceforge.net/project/numpy/NumPy/$v/numpy-$v.tar.gz

pack_set -s $IS_MODULE

if [ "x${pV:0:1}" == "x3" ]; then
    pack_set --install-query $(pack_get --prefix)/bin/f2py3
else
    pack_set --install-query $(pack_get --prefix)/bin/f2py
fi
pack_set --module-requirement $(get_parent) \
    --module-requirement fftw-3 --module-requirement umfpack

# For future maybe this flag is important: NPY_SEPARATE_COMPILATION=0

file=site.cfg
pack_set --command "echo '#' > $file"

tmp_lib=$(list --prefix ':' --loop-cmd 'pack_get --library-path' $(pack_get --module-requirement))
tmp_lib=${tmp_lib// /}
tmp_lib=${tmp_lib:1}:/usr/lib64:/lib64

tmp_inc=$(list --prefix ':' --suffix '/include' --loop-cmd 'pack_get --prefix' $(pack_get --module-requirement))
tmp_inc=${tmp_inc// /}
tmp_inc=${tmp_inc:1}

if $(is_c intel) ; then
    if [ -z "$MKL_PATH" ]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    pack_set --command "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_set --command "sed -i '$ a\
[DEFAULT]\n\
libraries = pthread,cholmod,ccolamd,camd,colamd,suitesparseconfig,iomp5\n\
library_dirs = $tmp_lib:$MKL_PATH/lib/intel64:$INTEL_PATH/lib/intel64\n\
include_dirs = $tmp_inc:$MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n' $file"

else
    pack_set --command "sed -i '1 a\
[DEFAULT]\n\
libraries = pthread,cholmod,ccolamd,camd,colamd,suitesparseconfig\n\
library_dirs = $tmp_lib\n\
include_dirs = $tmp_inc\n' $file"

fi

pack_set --command "sed -i '1 a\
[fftw]\n\
library_dirs = $(pack_get --library-path fftw-3)\n\
include_dirs = $(pack_get --prefix fftw-3)/include\n\
libraries = fftw3\n\
[amd]\n\
libraries = amd\n\
amd_libs = amd\n\
[umfpack]\n\
umfpack_libs = umfpack\n\
libraries = umfpack\n' $file"

# Check for Intel MKL or not
if $(is_c intel) ; then
    if [ -z "$MKL_PATH" ]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    pack_set --command "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_set --command "sed -i '$ a\
[mkl]\n\
library_dirs = $MKL_PATH/lib/intel64/:$INTEL_PATH/lib/intel64\n\
include_dirs = $MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n\
mkl_libs = mkl_rt,mkl_intel_lp64,mkl_gf_lp64,mkl_intel_thread,mkl_core,mkl_def\n\
lapack_libs = mkl_lapack95_lp64\n\
blas_libs = mkl_blas95_lp64' $file"

    p_flags="$INTEL_LIB $MKL_LIB -mkl=parallel -fp-model strict $FLAG_OMP -I$(pack_get --prefix ss_config)/include"
    pack_set --command "sed -i -e \"s:cc_exe = 'icc:cc_exe = 'icc ${pCFLAGS//-O3/-O2} $p_flags:g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e \"s/linker_exe=compiler,/linker_exe=compiler,archiver = ['$AR', '-cr'],/g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's|\(-shared\)|\1 -L${tmp_lib//:/ -L} -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=} $p_flags|g' numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's/\"ar\",/\"$AR\",/g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:opt = \[\]:opt = \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:F90:F77:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's|^\([[:space:]]*\)\(def get_flags_arch(self):.*\)|\1\2\n\1\1return \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]|g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e \"/'linker_so'/s|\(.-shared.\)|\1,'-L${tmp_lib//:/ -L}','-Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=}','$p_flags'|g\" numpy/distutils/fcompiler/intel.py"
    pack_set --command "$(get_parent_exec) setup.py config" \
	--command-flag "--compiler=intelem" \
	--command-flag "--fcompiler=intelem" 

elif $(is_c gnu) ; then

    if [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '$ a\
[atlas_threads]\n\
library_dirs = $(pack_get --library-path atlas)\n\
include_dirs = $(pack_get --prefix atlas)/include\n\
libraries = ptf77blas,ptcblas,ptatlas,pthread\n\
[atlas]\n\
library_dirs = $(pack_get --library-path atlas)\n\
include_dirs = $(pack_get --prefix atlas)/include\n\
libraries = f77blas,cblas,atlas\n\
[lapack]\n\
library_dirs = $(pack_get --library-path atlas)\n\
include_dirs = $(pack_get --prefix atlas)/include\n\
libraries = lapack' $file" 
    elif [ $(pack_installed openblas) -eq 1 ]; then
	tmp=$(pack_get --prefix openblas)
	pack_set --module-requirement openblas
	pack_set --command "sed -i '$ a\
[openblas]\n\
library_dirs = $tmp/lib\n\
include_dirs = $tmp/include\n\
libraries = openblas\n\
[blas]\n\
library_dirs = $tmp/lib\n\
include_dirs = $tmp/include\n\
libraries = openblas\n\
[lapack]\n\
library_dirs = $tmp/lib\n\
include_dirs = $tmp/include\n\
libraries = lapack' $file" 
    else
	tmp=$(pack_get --prefix blas)
	pack_set --module-requirement blas
	pack_set --command "sed -i '$ a\
[blas]\n\
library_dirs = $tmp/lib\n\
include_dirs = $tmp/include\n\
libraries = blas\n\
[lapack]\n\
library_dirs = $tmp/lib\n\
include_dirs = $tmp/include\n\
libraries = lapack' $file"
    fi

    # Add the flags to the EXTRAFLAGS for the GNU compiler
    p_flags="DUM ${pFCFLAGS} -I$(pack_get --prefix ss_config)/include $FLAG_OMP"
    # Create the list of flags in format ",'-<flag1>','-<flag2>',...,'-<flagN>'"
    p_flags="$(list --prefix ,\' --suffix \' ${p_flags//O3/O2} -L${tmp_lib//:/ -L} -L$tmp/lib -Wl,-rpath=$tmp/lib -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=})"
    # The DUM variable is to terminate (list) argument grabbing
    pack_set --command "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:9}\]|g\" numpy/distutils/fcompiler/gnu.py"
    pack_set --command "sed -i -e 's|\(-Wall\)\(.\)|\1\2,\2-fPIC\2|g' numpy/distutils/fcompiler/gnu.py"
    pack_set --command "unset LDFLAGS && $(get_parent_exec) setup.py config" \
	--command-flag "--compiler=unix --fcompiler=gnu95" 
    
else
    doerr numpy "Have not been configured with recognized compiler"

fi

# Install commands that it should run
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

add_test_package
pack_set --command "nosetests --exe numpy > tmp.test 2>&1 ; echo 'Succes'"
pack_set_mv_test tmp.test

done
