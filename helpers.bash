msg_install --message "Installing all helper modules if needed..."

# Install modules
source helpers/modules.bash

source helpers/gnumake.bash

source helpers/help2man.bash
source helpers/m4.bash
source helpers/autoconf.bash
source helpers/automake.bash
source helpers/libtool.bash
source helpers/cmake.bash
source helpers/freetype.bash

function echo_modules {
    # Retrieve all modules 
    local mods=""
    while [ $# -gt 0 ]; do
	mods="$(pack_get --module-requirement $1) $1"
	shift
    done
    # Remove duplicates
    mods="$(rem_dup $mods)"
    local echos=""
    for mod in $mods ; do
	local tmp=$(pack_get --module-name $mod)
	local tmp=${tmp//\/$(get_c)/}
	echos="$echos $tmp"
    done
    _ps "Loading: $echos"
}

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for build tools." \
    -M build-tools.npa \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules make help2man m4 autoconf automake libtool cmake)" \
    $(list --prefix '-RL ' make help2man m4 autoconf automake libtool cmake)
unset echo_modules

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash

# Install LLVM generically
source helpers/zlib.bash
source helpers/libffi.bash
source helpers/llvm.bash

source helpers/numactl.bash
#source helpers/libxml2.bash

# Install git for those who want the newest release
source helpers/git.bash
