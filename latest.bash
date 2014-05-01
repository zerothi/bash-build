msg_install --message "Will install latest modules now"

# Revert to the first build
build_set --default-build

# Source the file for obtaining correct env-variables
tmp=$(build_get --default-build)
source $(build_get --source[$tmp])
unset tmp

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
    -n "Nick Papior Andersen's script for loading Inelastica: $(get_c)" \
    -M Inelastica.latest/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules Inelastica-DEV)" \
    -RL Inelastica-DEV

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta.latest/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules siesta-dev)" \
    -RL siesta-dev

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta-scf.latest/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules siesta-scf)" \
    -RL siesta-scf

unset echo_modules
