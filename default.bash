msg_install --message "Will install default modules now"

cm_defs="-P /directory/should/not/exist --module-path $(build_get --module-path)-apps"

# Source the file for obtaining correct env-variables
source $(build_get --source)

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

msg_install --message "abinit, octopus, elk, q-espresso"

create_module $cm_defs \
    -n "abinit.default" \
    -W "Abinit: $(get_c)" \
    -M abinit.default \
    -echo "$(echo_modules abinit)" \
    -RL abinit

create_module $cm_defs \
    -n "octopus.default" \
    -W "Octopus: $(get_c)" \
    -M octopus.default \
    -echo "$(echo_modules octopus)" \
    -RL octopus

create_module $cm_defs \
    -n "elk.default" \
    -W "Elk: $(get_c)" \
    -M elk.default \
    -echo "$(echo_modules elk)" \
    -RL elk

create_module $cm_defs \
    -n "gulp.default" \
    -W "GULP: $(get_c)" \
    -M gulp.default \
    -echo "$(echo_modules gulp)" \
    -RL gulp

create_module $cm_defs \
    -n "q-espresso.default" \
    -W "QuantumEspresso: $(get_c)" \
    -M q-espresso.default \
    -echo "$(echo_modules q-espresso)" \
    -RL q-espresso


msg_install --message "Inelastica"

create_module $cm_defs \
    -n "Inelastica.default" \
    -W "Inelastica: $(get_c)" \
    -M Inelastica.default \
    -echo "$(echo_modules Inelastica-dev)" \
    -RL Inelastica-dev


msg_install --message "siesta and its variants"

create_module $cm_defs \
    -n siesta.default \
    -W "SIESTA: $(get_c)" \
    -M siesta.default \
    -echo "$(echo_modules siesta[4.0.2])" \
    -RL siesta[4.0.2]

create_module $cm_defs \
    -n siesta-master.default \
    -W "SIESTA: $(get_c)" \
    -M siesta-master.default \
    -echo "$(echo_modules siesta-master)" \
    -RL siesta-master


msg_install --message "openmx, vasp, dftb"

create_module $cm_defs \
    -n openmx.default \
    -W "OpenMX: $(get_c)" \
    -M openmx.default \
    -echo "$(echo_modules openmx)" \
    -RL openmx

create_module $cm_defs \
    -n vasp.default \
    -W "VASP: $(get_c)" \
    -M vasp.default \
    -echo "$(echo_modules vasp)" \
    -RL vasp

create_module $cm_defs \
    -n dftbplus.default \
    -W "DFTB+: $(get_c)" \
    -M dftbplus.default \
    -echo "$(echo_modules dftbplus)" \
    -RL dftbplus

msg_install --message "performance analysis"

tmp=
for i in papi valgrind pdt tau extrae paraver dimemas scorep
do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
#rm_latest performance-analysis.default/$(get_c)
create_module $cm_defs \
    -n performance-analysis.default \
    -W "Performance analysis routines: $(get_c)" \
    -M performance-analysis.default \
    -echo "$(echo_modules $tmp)" \
    $(list --prefix '-RL ' $tmp)

unset echo_modules
