msg_install --message "Will install default modules now"

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
    -M Inelastica.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules Inelastica-DEV[224])" \
    -RL Inelastica-DEV[224]

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading QuantumEspresso: $(get_c)" \
    -M espresso.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules espresso)" \
    -RL espresso

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules siesta-trunk[464])" \
    -RL siesta-trunk[464]

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading OpenMX: $(get_c)" \
    -M openmx.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules openmx[3.7])" \
    -RL openmx[3.7]

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading VASP: $(get_c)" \
    -M vasp.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules vasp[5.3.3-fftw3])" \
    -RL vasp[5.3.3-fftw3]

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading plotting routines: $(get_c)" \
    -M plot.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules gnuplot molden grace xcrysden povray vmd matplotlib)" \
    $(list --prefix '-RL ' gnuplot molden grace xcrysden povray vmd matplotlib)

unset echo_modules