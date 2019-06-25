for v in 1.16.4 ; do
add_package \
     https://github.com/numpy/numpy/releases/download/v$v/numpy-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

if [[ "x${pV:0:1}" == "x3" ]]; then
    pack_set -install-query $(pack_get -prefix)/bin/f2py3
else
    pack_set -install-query $(pack_get -prefix)/bin/f2py2
fi
pack_set -module-requirement cython
pack_set -module-requirement suitesparse

pack_cmd "mkdir -p $(pack_get -prefix)/lib/python$pV/site-packages/"

# For future maybe this flag is important: NPY_SEPARATE_COMPILATION=0

file=site.cfg
pack_cmd "echo '#' > $file"

tmp_lib=$(list -prefix ':' -loop-cmd 'pack_get -LD' $(pack_get -mod-req-path))
tmp_lib=${tmp_lib// /}
tmp_lib=${tmp_lib}:/usr/lib64:/lib64:/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu

tmp_inc=$(list -prefix ':' -suffix '/include' -loop-cmd 'pack_get -prefix' $(pack_get -mod-req-path))
tmp_inc=${tmp_inc// /}

pack_cmd "sed -i '1 a\
[fftw2]\n\
library_dirs = $(pack_get -LD fftw-2)\n\
include_dirs = $(pack_get -prefix fftw-2)/include\n\
fftw_libs = fftw_threads\n\
runtime_library_dirs = $(pack_get -LD fftw-2)\n\
[fftw]\n\
library_dirs = $(pack_get -LD fftw)\n\
include_dirs = $(pack_get -prefix fftw)/include\n\
fftw_libs = fftw3_threads\n\
runtime_library_dirs = $(pack_get -LD fftw)\n\
[amd]\n\
amd_libs = amd\n\
include_dirs = $(pack_get -prefix suitesparse)/include\n\
library_dirs = $(pack_get -LD suitesparse)\n\
runtime_library_dirs = $(pack_get -LD suitesparse)\n\
[umfpack]\n\
umfpack_libs = umfpack\n\
include_dirs = $(pack_get -prefix suitesparse)/include\n\
library_dirs = $(pack_get -LD suitesparse)\n\
runtime_library_dirs = $(pack_get -LD suitesparse)\n' $file"

# Check for Intel MKL or not
if $(is_c intel) ; then

    if [[ -z "$MKL_PATH" ]]; then
	doerr "numpy" "MKL_PATH is not defined in your source file (export)"
    fi
    pack_cmd "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_cmd "sed -i '$ a\
[mkl]\n\
library_dirs = $MKL_PATH/lib/intel64/:$INTEL_PATH/lib/intel64\n\
include_dirs = $MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n\
mkl_libs = mkl_lapack95_lp64,mkl_blas95_lp64,mkl_rt,mkl_intel_lp64,mkl_intel_thread,mkl_core,mkl_def\n\
lapack_libs = mkl_lapack95_lp64\n\
blas_libs = mkl_blas95_lp64' $file"

    p_flags="$INTEL_LIB $MKL_LIB -mkl=parallel -fp-model precise -fp-model source $FLAG_OMP -I$(pack_get -prefix suitesparse)/include"
    pack_cmd "sed -i -e \"s:cc_exe = 'icc:cc_exe = 'icc ${pCFLAGS//-O3/-O2} $p_flags:g\" numpy/distutils/intelccompiler.py"
    pack_cmd "sed -i -e \"s/linker_exe=compiler,/linker_exe=compiler,archiver = ['$AR', '-cr'],/g\" numpy/distutils/intelccompiler.py"
    pack_cmd "sed -i -e 's|\(-shared\)|\1 -L${tmp_lib//:/ -L} -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=} $p_flags|g' numpy/distutils/intelccompiler.py"
    pack_cmd "sed -i -e 's/\"ar\",/\"$AR\",/g' numpy/distutils/fcompiler/intel.py"
    pack_cmd "sed -i -e 's:opt = \[\]:opt = \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]:g' numpy/distutils/fcompiler/intel.py"
    pack_cmd "sed -i -e 's:F90:F77:g' numpy/distutils/fcompiler/intel.py"
    pack_cmd "sed -i -e 's|^\([[:space:]]*\)\(def get_flags_arch(self):.*\)|\1\2\n\1\1return \[\"${pFCFLAGS//-O3/-O2} $p_flags\"\]|g' numpy/distutils/fcompiler/intel.py"
    pack_cmd "sed -i -e \"/'linker_so'/s|\(.-shared.\)|\1,'-L${tmp_lib//:/ -L}','-Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=}','$p_flags'|g\" numpy/distutils/fcompiler/intel.py"

    pack_cmd "sed -i -e 's/\(suitesparseconfig\)/\1,iomp5/' $file"
    pack_cmd "sed -i '1 a\
[ALL]\n\
libraries = umfpack,cholmod,ccolamd,camd,colamd,amd,suitesparseconfig,iomp5,pthread\n\
library_dirs = $tmp_lib:$MKL_PATH/lib/intel64:$INTEL_PATH/lib/intel64\n\
runtime_library_dirs = $tmp_lib\n\
include_dirs = $tmp_inc:$MKL_PATH/include/intel64/lp64:$MKL_PATH/include:$INTEL_PATH/include/intel64:$INTEL_PATH/include\n' $file"

elif $(is_c gnu) ; then

    # numpy/distutils/system_info.py checks for MKLROOT!
    # We don't want that.
    pack_cmd "unset MKLROOT"

    if [[ $(vrs_cmp $v 1.10.0) -lt 0 ]]; then
	pack_cmd "sed -i -e 's|\(def check_embedded_lapack.*\)|\1\n\ \ \ \ \ \ \ \ return True|g' numpy/distutils/system_info.py"
    fi
    pack_cmd "sed -i -e '/_lib_names[ ]*=/s|openblas|openblas_omp|g' numpy/distutils/system_info.py"
    pack_cmd "sed -i -e '/_lib_names[ ]*=/s|blis|blis_omp|g' numpy/distutils/system_info.py"

    la=$(pack_choice -i linalg)
    if [[ $(vrs_cmp $v 1.16) -le 0 ]]; then
	la=openblas
    fi
    pack_set -module-requirement $la
    tmp="$(pack_get -LD $la)"
    case $la in
	openblas)
	    # lapack internally
	    noop
	    ;;
	atlas)
	    pack_cmd "sed -i '$ a\
[lapack]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
libraries = lapack_atlas\n\
runtime_library_dirs = $tmp\n' $file"
	    ;;
	*)
	    pack_set -module-requirement lapack
	    pack_cmd "sed -i '$ a\
[openblas]\n\
library_dirs = $(pack_get -LD lapack)\n\
include_dirs = $(pack_get -prefix lapack)/include\n\
libraries = lapack\n\
extra_link_args = -lgfortran -lm\n\
runtime_library_dirs = $(pack_get -LD lapack)\n' $file"
	    tmp="$(pack_get -LD $la)"
	    ;;
    esac
    tmp_l=$(pack_get -lib[omp] $la)
    tmp_l=${tmp_l//-l/,}
    case $la in
	atlas)
	    pack_cmd "sed -i '$ a\
[atlas_threads]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
libraries = $tmp_l,pthread\n\
runtime_library_dirs = $tmp\n' $file"
	    tmp_l=$(pack_get -lib $la)
	    tmp_l=${tmp_l//-l/,}
	    pack_cmd "sed -i '$ a\
[atlas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
libraries = $tmp_l\n\
runtime_library_dirs = $tmp\n' $file" 
	    ;;
	openblas)
	    pack_cmd "sed -i '$ a\
[openblas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
libraries = $tmp_l\n\
extra_link_args = -lpthread -lgfortran -lm $FLAG_OMP\n\
runtime_library_dirs = $tmp\n' $file"
	    ;;
	blas)
	    pack_cmd "sed -i '$ a\
[blas]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
blas_libs = $tmp_l\n\
libraries = $tmp_l\n\
runtime_library_dirs = $tmp\n' $file"
	    ;;
	blis)
	    pack_cmd "sed -i '$ a\
[blis]\n\
library_dirs = $tmp\n\
include_dirs = $(pack_get -prefix $la)/include\n\
libraries = $tmp_l\n\
extra_link_args = -lpthread -lm $FLAG_OMP\n\
runtime_library_dirs = $tmp\n' $file"
	    ;;
	*)
	    doerr "numpy" "Could not find linear-algebra library: $la"
	    ;;
    esac

    pack_cmd "sed -i '1 a\
[ALL]\n\
libraries = umfpack,cholmod,ccolamd,camd,colamd,amd,suitesparseconfig,pthread\n\
library_dirs = $tmp_lib\n\
include_dirs = $tmp_inc\n\
runtime_library_dirs = $tmp_lib\n' $file"

    # Add the flags to the EXTRAFLAGS for the GNU compiler
    p_flags="DUM ${pFCFLAGS} -I$(pack_get -prefix suitesparse)/include $FLAG_OMP"
    # Create the list of flags in format ",'-<flag1>','-<flag2>',...,'-<flagN>'"
    p_flags="$(list -prefix ,\' -suffix \' ${p_flags//O3/O2} $FLAG_OMP -L${tmp_lib//:/ -L} -L$tmp -Wl,-rpath=$tmp -Wl,-rpath=${tmp_lib//:/ -Wl,-rpath=})"
    # The DUM variable is to terminate (list) argument grabbing
    pack_cmd "sed -i -e \"s|_EXTRAFLAGS = \[\]|_EXTRAFLAGS = \[${p_flags:8}\]|g\" numpy/distutils/fcompiler/gnu.py"
    pack_cmd "sed -i -e 's|\(-Wall\)\(.\)|\1\2,\2-fPIC\2|g' numpy/distutils/fcompiler/gnu.py"

    # Correct the f77 designations in the blas_opt linkers
    # sadly the fortran linker does not obey the env-variables
    pack_cmd "sed -i -e 's|\(info\[.language.\] = .\)f77|\1c|g' numpy/distutils/system_info.py"
    
else
    doerr numpy "Have not been configured with recognized compiler"

fi

# Enables distutils to setup correct LDFLAGS for current python installation
pack_cmd "export LDSHARED='$CC -shared -pthread $LDFLAGS'"
pack_cmd "unset LDFLAGS"

#pack_cmd "$(get_parent_exec) setup.py config $pNumpyInstall"
#pack_cmd "$(get_parent_exec) setup.py build_clib $pNumpyInstall"
#pack_cmd "$(get_parent_exec) setup.py build_ext $pNumpyInstall"
pack_cmd "$(get_parent_exec) setup.py build $pNumpyInstall"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"

# Override the OMP_NUM_THREADS to 1, the user must only set the env' var after
# loading
pack_set -module-opt "-set-ENV OMP_NUM_THREADS=1"
pack_cmd "unset LDSHARED"


if ! $(is_c intel) ; then
    add_test_package numpy.test
    pack_cmd "unset LDFLAGS"
    if [[ $(vrs_cmp $v 1.15.0) -ge 0 ]]; then
	pack_cmd "OMP_NUM_THREADS=$NPROCS pytest --pyargs numpy > $TEST_OUT 2>&1 ; echo 'Success'"
    else
	pack_cmd "OMP_NUM_THREADS=$NPROCS nosetests --exe numpy > $TEST_OUT 2>&1 ; echo 'Success'"
    fi
    pack_store $TEST_OUT
fi

done
