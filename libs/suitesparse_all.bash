msg_install --message "Installing the SUITE SPARSE libraries..."

v=4.5.3
add_package \
    --alias suitesparse \
    --directory SuiteSparse \
    http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuitesparseconfig.a

# We do not use the build-in metis library
# According to SuiteSparse the only changes are:
#  default integers => long
#  removal of comments (for some compiler types)
#  removal of compiler warnings
# Basically nothing has changed.
pack_set --mod-req metis

if $(is_c intel) ; then
    pack_set --host-reject $(get_hostname)
fi

pack_cmd "module load $(list ++cmake)"

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
ssb "MY_METIS_LIB = $(list --LD-rp metis) -lmetis"
ssb "MY_METIS_INC = $(pack_get -prefix metis)/include"

sse " "
sse "# NPA make file for suitesparse"
sse "CC = $CC"
sse "CXX = $CXX"
sse "CFLAGS = $CFLAGS"
sse "CF = \$(CFLAGS) \$(CPPFLAGS) \$(TARGET_ARCH) -fexceptions -fPIC"
sse "CFOPENMP = $FLAG_OMP"
sse "CF += \$(CFOPENMP)"
sse "RANLIB = ranlib"
sse "ARCHIVE = \$(AR) \$(ARFLAGS)"
sse "CP = cp -f"
sse "MV = mv -f"
sse "F77 = $FC"
sse "F77FLAGS = $FCFLAGS"


# Add lapack/blas
# Check for Intel MKL or not
if $(is_c intel) ; then
    sse "BLAS = $MKL_LIB $INTEL_LIB -lmkl_blas95_lp64"
    sse "LAPACK = $MKL_LIB $INTEL_LIB -lmkl_lapack95_lp64"

else

    # This ensures that the linking step using
    # the C-compiler will work.
    sse "LBLIBS += -lgfortran"

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    sse "LAPACK = $(list --LD-rp +$la) $(pack_get -lib $la)"
    sse "BLAS = \$(LAPACK)"

fi

# No GPU support
ssb "GPU_CONFIG = "

unset ssb
unset sse

pack_cmd "make"
# Install commands that it should run
pack_cmd "make install INSTALL=$(pack_get --prefix)"
