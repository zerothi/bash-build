for v in 1.9.1 ; do
add_package http://downloads.sourceforge.net/project/numpy/NumPy/$v/numpy-$v.tar.gz

pack_set -s $IS_MODULE

if [ "x${pV:0:1}" == "x3" ]; then
    pack_set --install-query $(pack_get --prefix)/bin/f2py3
else
    pack_set --install-query $(pack_get --prefix)/bin/f2py
fi
pack_set $(list -p '-mod-req ' fftw-2 fftw-3 umfpack)

# For future maybe this flag is important: NPY_SEPARATE_COMPILATION=0

file=site.cfg
pack_set --command "echo '#' > $file"

tmp_lib=$(list --prefix ':' --loop-cmd 'pack_get --LD' $(pack_get --mod-req-path))
tmp_lib=${tmp_lib// /}
tmp_lib=${tmp_lib:1}:/usr/lib64:/lib64:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu

tmp_inc=$(list --prefix ':' --suffix '/include' --loop-cmd 'pack_get --prefix' $(pack_get --mod-req-path))
tmp_inc=${tmp_inc// /}
tmp_inc=${tmp_inc:1}

pack_set --command "sed -i '1 a\
[fftw2]\n\
library_dirs = $(pack_get --LD fftw-2)\n\
include_dirs = $(pack_get --prefix fftw-2)/include\n\
libraries = fftw_threads\n\
runtime_library_dirs = $(pack_get --LD fftw-2)\n\
[fftw]\n\
library_dirs = $(pack_get --LD fftw-3)\n\
include_dirs = $(pack_get --prefix fftw-3)/include\n\
libraries = fftw3_threads\n\
runtime_library_dirs = $(pack_get --LD fftw-3)\n\
[amd]\n\
libraries = amd\n\
include_dirs = $(pack_get --prefix amd)/include\n\
library_dirs = $(pack_get --LD amd)\n\
runtime_library_dirs = $(pack_get --LD amd)\n\
[umfpack]\n\
libraries = umfpack\n\
include_dirs = $(pack_get --prefix umfpack)/include\n\
library_dirs = $(pack_get --LD umfpack)\n\
runtime_library_dirs = $(pack_get --LD umfpack)\n' $file"

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

    p_flags="$INTEL_LIB $MKL_LIB -mkl=parallel -fp-model precise -fp-model source $FLAG_OMP -I$(pack_get --prefix ss_config)/include"
    pack_set --command "sed -i -e \"s:cc_exe = 'icc:cc_exe = 'icc ${pCFLAGS//-O3/-O2} $p_flags:g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e \"s/linker_exe=compiler,/linker_exe=compiler,archiver = ['$AR', '-cr'],/g\" numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's|\(-shared\)|\1 -L${tmp_lib//:/ -L} -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=} $p_flags|g' numpy/distutils/intelccompiler.py"
    pack_set --command "sed -i -e 's/\"ar\",/\"$AR\",/g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:opt = \[\]:opt = \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's:F90:F77:g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e 's|^\([[:space:]]*\)\(def get_flags_arch(self):.*\)|\1\2\n\1\1return \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]|g' numpy/distutils/fcompiler/intel.py"
    pack_set --command "sed -i -e \"/'linker_so'/s|\(.-shared.\)|\1,'-L${tmp_lib//:/ -L}','-Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=}','$p_flags'|g\" numpy/distutils/fcompiler/intel.py"

    pack_set --command "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_set --command "sed -i '1 a\
[ALL]\n\
libraries = umfpack,cholmod,ccolamd,camd,colamd,suitesparseconfig,iomp5,pthread\n\
library_dirs = $tmp_lib:$MKL_PATH/lib/intel64:$INTEL_PATH/lib/intel64\n\
runtime_library_dirs = $tmp_lib\n\
include_dirs = $tmp_inc:$MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n' $file"

elif $(is_c gnu) ; then

    # Force embedded_lapack (until 
    pack_set --command "sed -i -e 's|\(def check_embedded_lapack.*\)|\1\n\ \ \ \ \ \ \ \ return True|g' numpy/distutils/system_info.py"
    pack_set --command "sed -i -e '/_lib_names[ ]*=/s|openblas|openblasp|g' numpy/distutils/system_info.py"

    for la in $(choice linalg) ; do
	if [ $(pack_installed $la) -eq 1 ]; then
	    pack_set --module-requirement $la
	    tmp="$(pack_get --LD $la)"
	    pack_set --command "sed -i '$ a\
[lapack]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = lapack\n\
runtime_library_dirs = $tmp\n' $file" 
	    
	    if [ "x$la" == "xatlas" ]; then
		pack_set --command "sed -i '$ a\
[atlas_threads]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = ptf77blas,ptcblas,ptatlas,pthread\n\
runtime_library_dirs = $tmp\n\
[atlas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = f77blas,cblas,atlas\n\
runtime_library_dirs = $tmp\n' $file" 
	    elif [ "x$la" == "xopenblas" ]; then
		pack_set --command "sed -i '$ a\
[atlas]\n\
libraries = openblasp\n\
[openblas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = lapack,openblasp\n\
extra_link_args = -lpthread -lgfortran\n\
runtime_library_dirs = $tmp\n\
embedded_lapack = True\n\
[blas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = openblasp -lgfortran\n\
runtime_library_dirs = $tmp\n' $file"
	    elif [ "x$la" == "xblas" ]; then
		pack_set --command "sed -i '$ a\
[blas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get --prefix $la)/include\n\
libraries = blas\n\
runtime_library_dirs = $tmp\n' $file"
	    else
		doerr "numpy" "Could not find linear-algebra library: $la"
	    fi
	    break
	fi
    done

    pack_set --command "sed -i '1 a\
[ALL]\n\
libraries = umfpack,cholmod,ccolamd,camd,colamd,suitesparseconfig,pthread\n\
library_dirs = $tmp_lib\n\
include_dirs = $tmp_inc\n\
runtime_library_dirs = $tmp_lib\n' $file"

    # Add the flags to the EXTRAFLAGS for the GNU compiler
    p_flags="DUM ${pFCFLAGS} -I$(pack_get --prefix ss_config)/include $FLAG_OMP"
    # Create the list of flags in format ",'-<flag1>','-<flag2>',...,'-<flagN>'"
    p_flags="$(list --prefix ,\' --suffix \' ${p_flags//O3/O2} -L${tmp_lib//:/ -L} -L$tmp -Wl,-rpath=$tmp -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=})"
    # The DUM variable is to terminate (list) argument grabbing
    pack_set --command "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:9}\]|g\" numpy/distutils/fcompiler/gnu.py"
    pack_set --command "sed -i -e 's|\(-Wall\)\(.\)|\1\2,\2-fPIC\2|g' numpy/distutils/fcompiler/gnu.py"

    # Correct the f77 designations in the blas_opt linkers
    # sadly the fortran linker does not obey the env-variables
    pack_set --command "sed -i -e 's|\(info\[.language.\] = .\)f77|\1c|g' numpy/distutils/system_info.py"
    
else
    doerr numpy "Have not been configured with recognized compiler"

fi

# Enables distutils to setup correct LDFLAGS for current python installation
pack_set --command "export LDSHARED='$CC -shared -pthread $LDFLAGS'"
pack_set --command "unset LDFLAGS"

pack_set --command "CC=$CC $(get_parent_exec) setup.py config $pNumpyInstall"
pack_set --command "CC=$CC $(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --prefix)"

# Override the OMP_NUM_THREADS to 1, the user must only set the env' var after
# loading
pack_set --module-opt "--set-ENV OMP_NUM_THREADS=1"
pack_set --command "unset LDSHARED"


add_test_package
pack_set --command "unset LDFLAGS"
pack_set --command "nosetests --exe numpy > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test

done
