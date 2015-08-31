msg_install --message "Will install default modules now"

cm_defs="-P /directory/should/not/exist --module-path $(build_get --module-path)-npa-apps"

# Source the file for obtaining correct env-variables
source $(build_get --source)

function echo_modules {
    # Retrieve all modules 
    local mods=""
    while [[ $# -gt 0 ]]; do
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

msg_install --message "abinit, octopus, elk, espresso"

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading Abinit: $(get_c)" \
    -M abinit.default/$(get_c) \
    -echo "$(echo_modules abinit)" \
    -RL abinit

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading Octopus: $(get_c)" \
    -M octopus.default/$(get_c) \
    -echo "$(echo_modules octopus)" \
    -RL octopus

if [[ $(pack_get --installed elk) -eq 1 ]]; then
    create_module $cm_defs \
	-n "Nick Papior Andersen's script for loading Elk: $(get_c)" \
	-M elk.default/$(get_c) \
	-echo "$(echo_modules elk)" \
	-RL elk
fi

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading Gulp: $(get_c)" \
    -M gulp.default/$(get_c) \
    -echo "$(echo_modules gulp)" \
    -RL gulp

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading QuantumEspresso: $(get_c)" \
    -M espresso.default/$(get_c) \
    -echo "$(echo_modules espresso)" \
    -RL espresso

msg_install --message "Inelastica"

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading Inelastica: $(get_c)" \
    -M Inelastica.default/$(get_c) \
    -echo "$(echo_modules Inelastica-DEV[323])" \
    -RL Inelastica-DEV[323]

msg_install --message "siesta-dev, siesta-scf"

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta.default/$(get_c) \
    -echo "$(echo_modules siesta-dev[475])" \
    -RL siesta-dev[475]

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta-scf.default/$(get_c) \
    -echo "$(echo_modules siesta-scf)" \
    -RL siesta-scf

#msg_install --message "siesta-trunk"

#create_module $cm_defs \
#    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
#    -M siesta-trunk.default/$(get_c) \
#    -echo "$(echo_modules siesta-trunk)" \
#    -RL siesta-trunk

msg_install --message "openmx, vasp"

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading OpenMX: $(get_c)" \
    -M openmx.default/$(get_c) \
    -echo "$(echo_modules openmx)" \
    -RL openmx

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading VASP: $(get_c)" \
    -M vasp.default/$(get_c) \
    -echo "$(echo_modules vasp[5.3.5])" \
    -RL vasp[5.3.5]

create_module $cm_defs \
    -n "Nick Papior Andersen's script for loading plotting routines: $(get_c)" \
    -M plot.default/$(get_c) \
    -echo "$(echo_modules gnuplot molden grace xcrysden povray vmd matplotlib)" \
    $(list --prefix '-RL ' gnuplot molden grace xcrysden povray vmd matplotlib)

unset echo_modules
