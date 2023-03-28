jV=1.8
IjV=$jV.5
add_package -package julia \
	    -directory julia-$IjV \
	    https://github.com/JuliaLang/julia/releases/download/v$IjV/julia-$IjV-full.tar.gz

# The settings
pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/julia

# User has to specify thread count
pack_set --module-opt "--set-ENV JULIA_NUM_THREADS=1"
pack_set --module-opt "--set-ENV JULIA_CPU_THREADS=1"
pack_set --module-opt "--set-ENV JULIA_EXCLUSIVE=0"

# Create user makefile
pack_cmd "echo '# BBUILD' > Make.user"
pack_cmd "sed -i '1 a\
prefix = $(pack_get -prefix)\n\
JULIA_NUM_THREADS = 1\n\
' Make.user"

if $(is_c intel) ; then

    pack_cmd "sed -i '1 a\
USEICC = 1\n\
USEIFC = 1\n\
USE_SYSTEM_BLAS = 1\n\
LIBBLAS = $MKL_LIB -mkl=parallel\n\
LIBBLASNAME = libmkl_rt\n\
USE_SYSTEM_LAPACK = 1\n\
LIBLAPACK = $MKL_LIB -mkl=parallel\n\
LIBLAPACKNAME = libmkl_rt\n\
' Make.user"

else

    la=$(pack_choice -i linalg)
    case $la in
	openblas)
	    noop
	    ;;
	*)
	    # always prefer openblas (for now)
	    la=openblas
	    ;;
    esac
    pack_set -module-requirement lapack-$la

    pack_cmd "sed -i '1 a\
USEGCC = 1\n\
USE_SYSTEM_BLAS = 1\n\
LIBBLAS = $(list -LD-rp-lib[omp] +lapack-$la)\n\
LIBBLASNAME = lib${la}_omp\n\
USE_SYSTEM_LAPACK = 1\n\
LIBLAPACK = $(list -LD-rp-lib[omp] +lapack-$la)\n\
LIBLAPACKNAME = \$(LIBBLASNAME)\n\
LDFLAGS += $(list -LD-rp lapack-$la)\n\
' Make.user"

    pack_cmd "make -C deps distclean-openblas"
fi

pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"
if ! $(is_host nicpa) ; then
    # limit number of julia processors for tests
    pack_cmd "export JULIA_NUM_THREADS=$NPROCS"
    pack_cmd "export JULIA_CPU_THREADS=$NPROCS"
    pack_cmd "make test 2>&1 | tee julia.test"
    pack_store julia.test
fi
pack_store Make.user


# Create a new build with this module
new_build -name _internal-julia$IjV \
    -module-path $(build_get -module-path)-julia/$IjV \
    -source $(build_get -source) \
    $(list -prefix "-default-module " $(pack_get -mod-req-module) julia[$IjV]) \
    -installation-path $(dirname $(pack_get -prefix $(get_parent)))/packages \
    -build-module-path "-package -version" \
    -build-installation-path "$IjV -package -version" \
    -build-path $(build_get -build-path)/jul-$jV

mkdir -p $(build_get -module-path[_internal-julia$IjV])-apps
build_set -default-setting[_internal-julia$IjV] $(build_get -default-setting)

# Now add options to ensure that loading this module will enable the path for the *new build*
pack_set -module-opt "-use-path $(build_get -module-path[_internal-julia$IjV])"
case $_mod_format in
    $_mod_format_ENVMOD)
	;;
    *)
	pack_set -module-opt "-use-path $(build_get -module-path[_internal-julia$IjV])-apps"
	;;
esac

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
