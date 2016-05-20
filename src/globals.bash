

# Current working directory
_cwd=$(pwd)

if [[ -z "$LC_ALL" ]]; then
    # Set this for doing ANSI comparisons versus
    # unicode comparisons, much faster
    export LC_ALL=C
fi

# The error file
_ERROR_FILE=$_cwd/ERROR
# Clean the error file
rm -f $_ERROR_FILE

# Default debugging variables
_NS=1000000000
[ -z "$FORCEMODULE" ] && FORCEMODULE=0
[ -z "$DOWNLOAD" ] && DOWNLOAD=0
[ -z "$PACK_LIST" ] && PACK_LIST=0

# List of options for archival stuff
BUILD_DIR=build-dir
PRELOAD_MODULE=module-preload
IS_MODULE=module
CRT_DEF_MODULE=def-module
MAKE_PARALLEL=parallel

# To by-pass creating survey when using the install script
export NPA__SURVEY_IN=1

# A separator used for commands that can be given consequtively
_LIST_SEP='ø'
# Separator for choices
_CHOICE_SEP='@'


# Simple help print-out function

function help_() {
    echo "Usage: $0 [options] [build-file [...]]"
    echo "Options:"
    echo "  --mpi-version|-mpi <openmpi|mpich|mvapich>"
    echo "    specify the MPI library used as the default MPI dependency"
    echo "  --python-version|-pv <2|3>"
    echo "    determine the python version to be installed"
    echo "  --tcl/lua"
    echo "    create tcl (env-modules) or lua (Lmod) module files"
    echo "  --generic <build-name> [generic]"
    echo "    build used for generic builds (non-optimized)"
    echo "  --default|-opti|-d <build-name> [generic]"
    echo "    set the default build used for optimized compilations"
    echo "  --list"
    echo "    create package lists which may subsequently be passed to --only-file"
    echo "  --only <package>"
    echo "    reduce installation to only this package (+)"
    echo "  --only-file <file>"
    echo "    reduce installation to packages listed in <file> (+)"
    echo "  --build <file>"
    echo "    source <file> to add builds"
    echo "  --help|-h"
    echo "    show this help"
}
