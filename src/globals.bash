

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

# A separator used for commands that can be given consequtively
_LIST_SEP='ø'
# Separator for choices
_CHOICE_SEP='@'

# Whether we should create TCL or LUA module files
_module_format='TCL'
