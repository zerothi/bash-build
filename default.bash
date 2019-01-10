msg_install --message "Will install default modules now"

cm_defs="-P /directory/should/not/exist --module-path $(build_get --module-path)-npa-apps"

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
    _ps "Loading: $echos"
}

msg_install --message "abinit, octopus, elk, espresso"

create_module $cm_defs \
    -n "abinit.default" \
    -W "Nick R. Papior script for loading Abinit: $(get_c)" \
    -M abinit.default/$(get_c) \
    -echo "$(echo_modules abinit)" \
    -RL abinit

create_module $cm_defs \
    -n "octopus.default" \
    -W "Nick R. Papior script for loading Octopus: $(get_c)" \
    -M octopus.default/$(get_c) \
    -echo "$(echo_modules octopus)" \
    -RL octopus

create_module $cm_defs \
    -n "elk.default" \
    -W "Nick R. Papior script for loading Elk: $(get_c)" \
    -M elk.default/$(get_c) \
    -echo "$(echo_modules elk)" \
    -RL elk

create_module $cm_defs \
    -n "gulp.default" \
    -W "Nick R. Papior script for loading Gulp: $(get_c)" \
    -M gulp.default/$(get_c) \
    -echo "$(echo_modules gulp)" \
    -RL gulp

create_module $cm_defs \
    -n "espresso.default" \
    -W "Nick R. Papior script for loading QuantumEspresso: $(get_c)" \
    -M espresso.default/$(get_c) \
    -echo "$(echo_modules espresso)" \
    -RL espresso


msg_install --message "Inelastica"

create_module $cm_defs \
    -n "Inelastica.default" \
    -W "Nick R. Papior script for loading Inelastica: $(get_c)" \
    -M Inelastica.default/$(get_c) \
    -echo "$(echo_modules Inelastica-dev)" \
    -RL Inelastica-dev


msg_install --message "siesta and its variants"

create_module $cm_defs \
    -n siesta.default \
    -W "Nick R. Papior script for loading SIESTA: $(get_c)" \
    -M siesta.default/$(get_c) \
    -echo "$(echo_modules siesta[4.0])" \
    -RL siesta[4.0]

create_module $cm_defs \
    -n siesta-trunk.default \
    -W "Nick R. Papior script for loading SIESTA: $(get_c)" \
    -M siesta-trunk.default/$(get_c) \
    -echo "$(echo_modules siesta-trunk)" \
    -RL siesta-trunk


msg_install --message "openmx, vasp, dftb"

create_module $cm_defs \
    -n openmx.default \
    -W "Nick R. Papior script for loading OpenMX: $(get_c)" \
    -M openmx.default/$(get_c) \
    -echo "$(echo_modules openmx)" \
    -RL openmx

create_module $cm_defs \
    -n vasp.default \
    -W "Nick R. Papior script for loading VASP: $(get_c)" \
    -M vasp.default/$(get_c) \
    -echo "$(echo_modules vasp[5.3.5])" \
    -RL vasp[5.3.5]

create_module $cm_defs \
    -n dftbplus.default \
    -W "Nick R. Papior script for loading DFTB+: $(get_c)" \
    -M dftbplus.default/$(get_c) \
    -echo "$(echo_modules dftbplus)" \
    -RL dftbplus

msg_install --message "plotting utilities"

create_module $cm_defs \
    -n plot.default \
    -W "Nick R. Papior script for loading plotting routines: $(get_c)" \
    -M plot.default/$(get_c) \
    -echo "$(echo_modules gnuplot molden grace xcrysden povray vmd matplotlib)" \
    $(list --prefix '-RL ' gnuplot molden grace xcrysden povray vmd matplotlib)


msg_install --message "performance analysis"

tmp=
for i in papi valgrind pdt tau extrae paraver-kernel dimemas wxparaver
do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done

#rm_latest performance-analysis.default/$(get_c)
create_module $cm_defs \
    -n performance-analysis.default \
    -W "Nick R. Papior script for loading performance analysis routines: $(get_c)" \
    -M performance-analysis.default/$(get_c) \
    -echo "$(echo_modules $tmp)" \
    $(list --prefix '-RL ' $tmp)

unset echo_modules
