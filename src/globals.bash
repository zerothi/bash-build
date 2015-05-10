# Default debugging variables
_NS=1000000000
[ -z "$DEBUG" ] && DEBUG=0
[ -z "$FORCEMODULE" ] && FORCEMODULE=0
[ -z "$DOWNLOAD" ] && DOWNLOAD=0
[ -z "$PACK_LIST" ] && PACK_LIST=0

# List of options for archival stuff
BUILD_DIR=build-dir
PRELOAD_MODULE=module-preload
IS_MODULE=module
let "MAKE_PARALLEL=1 << 1"

# A separator used for commands that can be given consequetively
_LIST_SEP='ø'
