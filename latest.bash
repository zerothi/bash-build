msg_install --message "Will install latest modules now"

cm_defs="-P /directory/should/not/exist --module-path $(build_get --module-path)-npa-apps"

# Source the file for obtaining correct env-variables
source $(build_get --source)

function rm_latest {
    local latest_mod=$(build_get --module-path)-npa-apps
    rm -rf $latest_mod/$1
}

function echo_modules {
    # Retrieve all modules 
    local mods=""
    while [ $# -gt 0 ]; do
	mods="$(pack_get --mod-req $1) $1"
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

rm_latest Inelastica.latest/$(get_c)
create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading Inelastica: $(get_c)" \
    -M Inelastica.latest/$(get_c) \
    -echo "$(echo_modules Inelastica-DEV)" \
    -RL Inelastica-DEV

rm_latest siesta.latest/$(get_c)
create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta.latest/$(get_c) \
    -echo "$(echo_modules siesta-dev)" \
    -RL siesta-dev

rm_latest siesta-scf.latest/$(get_c)
create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta-scf.latest/$(get_c) \
    -echo "$(echo_modules siesta-scf)" \
    -RL siesta-scf

unset echo_modules
unset rm_latest