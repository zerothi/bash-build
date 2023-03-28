msg_install -message "Installing the SUITE SPARSE libraries..."

v=7.0.1
add_package \
    -alias suitesparse \
    -archive SuiteSparse-$v.tar.gz \
    https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/v$v.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -LD)/libsuitesparseconfig.so

# We do not use the build-in metis library
# According to SuiteSparse the only changes are:
#  default integers => long
#  removal of comments (for some compiler types)
#  removal of compiler warnings
# Basically nothing has changed.
pack_set -mod-req metis

mk=SuiteSparse_config/SuiteSparse_config.mk

# Create the suite sparse config file
function ssb() {
    pack_cmd "sed -i '1 a\
$@\n' $mk"
}
function sse() {
    pack_cmd "echo '$@' >> $mk"
}


# First insert the flags that control the flow at the top
ssb "JOBS = $NPROCS"
ssb "MY_METIS_LIB = $(list -LD-rp-lib metis)"
ssb "MY_METIS_INC = $(pack_get -prefix metis)/include"
ssb "LDFLAGS += \$(CFOPENMP)"
ssb "CF += \$(CFOPENMP)"
ssb "INSTALL = $(pack_get -prefix)/"
ssb "CF = \$(CFLAGS) \$(CPPFLAGS) \$(TARGET_ARCH) -fexceptions -fPIC"
ssb "CFOPENMP = $FLAG_OMP"
ssb "AUTOCC = no"
ssb "CC = $CC"
ssb "CXX = $CXX"
ssb "CFLAGS = $CFLAGS"
ssb "OPTIMIZATION = $CFLAGS"
ssb "ARCHIVE = \$(AR) \$(ARFLAGS)"
ssb "AR = $AR"
ssb "RANLIB = $RANLIB"
ssb "CP = cp -f"
ssb "MV = mv -f"
ssb "F77 = $FC"
ssb "F77FLAGS = $FCFLAGS"

# Add lapack/blas
# Check for Intel MKL or not
if $(is_c intel) ; then
    ssb "BLAS = $MKL_LIB $INTEL_LIB -lmkl_blas95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread"
    ssb "LAPACK = $MKL_LIB $INTEL_LIB -lmkl_lapack95_lp64 -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread"

else
    ssb "MKLROOT := "

    # This ensures that the linking step using
    # the C-compiler will work.
    sse "LDLIBS += -lgfortran"

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    ssb "LAPACK = $(list -LD-rp +$la) $(pack_get -lib[omp] $la)"
    ssb "BLAS = \$(LAPACK)"

fi

# No GPU support
ssb "GPU_CONFIG = "
ssb "CUDA = no"
sse "LDFLAGS += -L\$(INSTALL_LIB) -Wl,-rpath=\$(INSTALL_LIB)"
sse "LDLIBS += -L\$(INSTALL_LIB) -Wl,-rpath=\$(INSTALL_LIB)"

unset ssb
unset sse

if [[ $(vrs_cmp $v 5.8.0) -eq 0 ]]; then
    pack_cmd "sed -i -e 's:^CFLAGS +=:#CFLAGS +=:' SLIP_LU/Lib/Makefile"
fi

pack_cmd "JOBS=$NPROCS make config"
pack_cmd "JOBS=$NPROCS make library"
pack_cmd "JOBS=$NPROCS make static"
pack_cmd "JOBS=$NPROCS make install"
pack_cmd "cp $mk $(pack_get -prefix)/"

# In 5.4.0 the lib*.a are not installed, we need to do this manually
pack_cmd 'find ./ -name "lib*.a" -exec cp "{}" $(pack_get -prefix)/lib/ \;'

