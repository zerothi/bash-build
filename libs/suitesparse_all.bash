msg_install --message "Installing the SUITE SPARSE libraries..."

v=4.4.1
add_package \
    --alias suitesparse \
    --directory SuiteSparse \
    http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --LD)/libsuitesparseconfig.a

if $(is_c intel) ; then
    pack_set --host-reject $(get_hostname)
fi

mk=SuiteSparse_config/SuiteSparse_config.mk

# Create the suite sparse config file
pack_set --command "echo '# NPA make file for suitesparse' > $mk"
function sse() {
    pack_set --command "echo '$@' >> $mk"
}
sse "CC = $CC"
sse "CFLAGS = $CFLAGS"
sse "CF = \$(CFLAGS) \$(CPPFLAGS) \$(TARGET_ARCH) -fexceptions -fPIC"
sse "RANLIB = ranlib"
sse "ARCHIVE = \$(AR) \$(ARFLAGS)"
sse "CP = cp -f"
sse "MV = mv -f"
sse "F77 = $FC"
sse "F77FLAGS = $FCFLAGS"
sse "F77LIBS = "
sse "LIB = -lm -lrt"
sse "INSTALL_LIB = $(pack_get --LD)"
sse "INSTALL_INCLUDE = $(pack_get --prefix)/include"

# Add lapack/blas
# Check for Intel MKL or not
if $(is_c intel) ; then
    sse "BLAS = $MKL_LIB $INTEL_LIB -lmkl_blas95_lp64"
    sse "LAPACK = $MKL_LIB $INTEL_LIB -lmkl_lapack95_lp64"

else

    # This ensures that the linking step using
    # the C-compiler will work.
    sse "LIB += -lgfortran"

    if [ $(pack_installed openblas) -eq 1 ]; then
	pack_set --module-requirement openblas
	sse "BLAS = $(list --LDFLAGS --Wlrpath openblas) -lopenblas"
	sse "LAPACK = $(list --LDFLAGS --Wlrpath openblas) -llapack"
    elif [ $(pack_installed atlas) -eq 1 ]; then
	pack_set --module-requirement atlas
	sse "BLAS = $(list --LDFLAGS --Wlrpath atlas) -lf77blas -lcblas -latlas"
	sse "LAPACK = $(list --LDFLAGS --Wlrpath atlas) -llapack"
    else
	pack_set --module-requirement blas
	sse "BLAS = $(list --LDFLAGS --Wlrpath blas) -lblas"
	sse "LAPACK = $(list --LDFLAGS --Wlrpath blas) -llapack"
    fi

fi

# Force to use XERBLA distributed with the BLAS version
sse "XERBLA = "

# No GPU support
sse "GPU_CONFIG = "

# Add METIS
#pack_set --module-requirement metis
sse "METIS_PATH = $(pack_set --prefix metis)"
sse "METIS = $(pack_set --LD metis)/libmetis.a"
sse "METIS_PATH = ../../metis-4.0"
sse "METIS = ../../metis-4.0/libmetis.a"

# UMFpack configuration
sse "UMFPACK_CONFIG ="

# CHOLmod configuration
sse "CHOLMOD_CONFIG = \$(GPU_CONFIG)"

# QR configuration
sse "SPQR_CONFIG = \$(GPU_CONFIG)"

# standard 
sse "PRETTY = grep -v \"^\#\" | indent -bl -nce -bli0 -i4 -sob -l120"

# clean
sse "CLEAN = *.o *.obj *.ln *.bb *.bbg *.da *.tcov *.gcov gmon.out *.bak *.d *.gcda *.gcno"

unset sse

pack_set --command "make $(get_make_parallel)"
# Install commands that it should run
pack_set --command "mkdir -p $(pack_get --LD)/"
pack_set --command "mkdir -p $(pack_get --prefix)/include/"
pack_set --command "make install"
