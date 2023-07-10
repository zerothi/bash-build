msg_install -message "Installing the SUITE SPARSE libraries..."

v=7.0.1
add_package \
    -package suitesparse \
    -archive SuiteSparse-$v.tar.gz \
    https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v$v.tar.gz

pack_set -s $IS_MODULE -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -LD)/libsuitesparseconfig.so

# We do not use the build-in metis library
# According to SuiteSparse the only changes are:
#  default integers => long
#  removal of comments (for some compiler types)
#  removal of compiler warnings
# Basically nothing has changed.
pack_set -mod-req metis

opts=
opts="$opts -DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)"
if $(is_c gnu) ; then
  opts="$opts -DGMP_ROOT=$(pack_get -prefix gcc[$(get_c -v)])"
  opts="$opts -DMPFR_ROOT=$(pack_get -prefix gcc[$(get_c -v)])"
fi

# Add lapack/blas
# Check for Intel MKL or not
if $(is_c intel) ; then
    opts="$opts -DBLAS_LIBRARIES='$MKL_LIB $INTEL_LIB -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread'"
    opts="$opts -DLAPACK_LIBRARIES='$MKL_LIB $INTEL_LIB -lmkl_lapack95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread'"

else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    opts="$opts -DBLAS_LIBRARIES='$(list -LD-rp +$la) $(pack_get -lib[omp] $la)'"
    opts="$opts -DLAPACK_LIBRARIES='$(list -LD-rp +$la) $(pack_get -lib[omp] $la)'"

fi
opts="$opts -DENABLE_CUDA=OFF"

pack_cmd "make CMAKE_OPTIONS=\"$opts\" JOBS=$(get_parallel)"
pack_cmd "make CMAKE_OPTIONS=\"$opts\" install"

