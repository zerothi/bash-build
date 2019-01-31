msg_install --message "Will install latest modules now"

cm_defs="-P /directory/should/not/exist --module-path $(build_get --module-path)-apps"

# Source the file for obtaining correct env-variables
source $(build_get --source)

case $_mod_format in
    $_mod_format_ENVMOD)
	function rm_latest {
	    local latest_mod=$(build_get --module-path)-apps
	    rm -rf $latest_mod/$1
	}
	;;
    $_mod_format_LMOD)
	function rm_latest {
	    local latest_mod=$(build_get --module-path)-apps
	    rm -rf $latest_mod/$1.lua
	}
	;;
esac

function echo_modules {
    # Retrieve all modules 
    local mods=""
    while [[ $# -gt 0 ]]; do
	mods="$(pack_get --mod-req-module $1) $1"
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
    printf '%s' "Loading: $echos"
}

msg_install --message "Inelastica"

rm_latest Inelastica.latest
create_module $cm_defs \
    -n Inelastica.latest \
    -W "Inelastica: $(get_c)" \
    -M Inelastica.latest \
    -echo "$(echo_modules Inelastica-dev)" \
    -RL Inelastica-dev


msg_install --message "siesta and its variants"

rm_latest siesta.latest
create_module $cm_defs \
    -n siesta.latest \
    -W "Siesta: $(get_c)" \
    -M siesta.latest \
    -echo "$(echo_modules siesta)" \
    -RL siesta

rm_latest siesta-trunk.latest
create_module $cm_defs \
    -n siesta-trunk.latest \
    -W "Siesta: $(get_c)" \
    -M siesta-trunk.latest \
    -echo "$(echo_modules siesta-trunk)" \
    -RL siesta-trunk

rm_latest siesta-trunk-bulk-bias.latest
create_module $cm_defs \
    -n siesta-trunk-bulk-bias.latest \
    -W "Siesta: $(get_c)" \
    -M siesta-trunk-bulk-bias.latest \
    -echo "$(echo_modules siesta-trunk-bulk-bias)" \
    -RL siesta-trunk-bulk-bias


msg_install --message "lammps"

rm_latest lammps.latest
create_module $cm_defs \
    -n lammps.latest \
    -W "LAMMPS: $(get_c)" \
    -M lammps.latest \
    -echo "$(echo_modules lammps)" \
    -RL lammps

unset echo_modules
unset rm_latest
