jV=1.1
IjV=$pj.0
add_package -package julia \
	    -directory julia-$IjV \
	    https://github.com/JuliaLang/julia/releases/download/v$IjV/julia-$IjV-full.tar.gz

# The settings
pack_set -s $MAKE_PARALLEL -s $IS_MODULE
pack_set -module-requirement suitesparse

pack_set -install-query $(pack_get -prefix)/bin/julia

# Create user makefile
pack_cmd "echo '# BBUILD' > Make.user"
pack_cmd "sed -i '1 a\
prefix = $(pack_get -prefix)\n\
USE_SYSTEM_GMP = 1\n\
USE_SYSTEM_MPFR = 1\n\
USE_SYSTEM_SUITESPARSE = 1\n\
LDFLAGS += $(list -LD-rp suitesparse)\n\
' Make.user"

if $(is_c intel) ; then

    pack_cmd "sed -i '1 a\
USEGCC = 0\n\
USEICC = 1\n\
USE_SYSTEM_BLAS = 1\n\
LIBBLAS = $MKL_LIB -mkl=parallel\n\
LIBBLASNAME = libmkl_rt\n\
USE_SYSTEM_LAPACK = 1\n\
LIBLAPACK = $MKL_LIB -mkl=parallel\n\
LIBLAPACKNAME = libmkl_rt\n\
' Make.user"

else

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la

    pack_cmd "sed -i '1 a\
USEGCC = 1\n\
USEICC = 0\n\
USE_SYSTEM_BLAS = 1\n\
LIBBLAS = $(list -LD-rp-lib[omp] +$la)\n\
LIBBLASNAME = lib$(pack_choice -i linalg)\n\
USE_SYSTEM_LAPACK = 1\n\
LIBLAPACK = $(list -LD-rp-lib[omp] +$la)\n\
LIBLAPACKNAME = liblapack\n\
LDFLAGS += $(list -LD-rp $la)\n\
' Make.user"
fi

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

pack_store Make.user
pack_cmd "sthaeosuaosenatouh"


# Create a new build with this module
new_build -name _internal-julia$IjV \
    -module-path $(build_get -module-path)-julia/$IjV \
    -source $(build_get -source) \
    $(list -prefix "-default-module " $(pack_get -mod-req-module) julia[$IjV]) \
    -installation-path $(dirname $(pack_get -prefix $(get_parent)))/packages \
    -build-module-path "-package -version" \
    -build-installation-path "$IjV -package -version" \
    -build-path $(build_get -build-path)/py-$pV

build_set -default-choice[_internal-julia$IjV] linalg openblas blis atlas blas

# Now add options to ensure that loading this module will enable the path for the *new build*
pack_cmd "mkdir -p $(build_get -module-path[_internal-julia$IjV])-apps"
pack_set -module-opt "-use-path $(build_get -module-path[_internal-julia$IjV])"
pack_set -module-opt "-use-path $(build_get -module-path[_internal-julia$IjV])-apps"


pack_install


create_module \
    -module-path $(build_get -module-path)-apps \
    -n $(pack_get -alias).$(pack_get -version) \
    -W "Script for loading $(pack_get -package): $(get_c)" \
    -v $(pack_get -version) \
    -M $(pack_get -alias).$(pack_get -version) \
    -P "/directory/should/not/exist" \
    $(list -prefix '-L ' $(pack_get -module-requirement)) \
    -L $(pack_get -alias) 

# The lookup name in the list for version number etc...
set_parent $(pack_get -alias)[$IjV]
set_parent_exec $(pack_get -prefix)/bin/julia

# Save the default build index
def_idx=$(build_get -default-build)
# Change to the new build default
build_set -default-build _internal-julia$IjV


# Install all julia packages
source julia-install.bash
clear_parent

# Initialize the module read path
old_path=$(build_get -module-path)
build_set -module-path $old_path-apps
source julia/julia-mods.bash
build_set -module-path $old_path


# Reset default build
build_set -default-build $def_idx
