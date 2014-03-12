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
    -n "Nick Papior Andersen's script for loading Abinit: $(get_c)" \
    -M abinit.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules abinit)" \
    -RL abinit

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading Octopus: $(get_c)" \
    -M octopus.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules octopus)" \
    -RL octopus

if [ $(pack_get --installed elk) -eq 1 ]; then
    create_module \
	--module-path $(build_get --module-path)-npa-apps \
	-n "Nick Papior Andersen's script for loading Elk: $(get_c)" \
	-M elk.default/$(get_c) \
	-P "/directory/should/not/exist" \
	-echo "$(echo_modules elk)" \
	-RL elk
fi

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading Inelastica: $(get_c)" \
    -M Inelastica.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules Inelastica-DEV[228])" \
    -RL Inelastica-DEV[228]

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
    -echo "$(echo_modules siesta-dev[470])" \
    -RL siesta-dev[470]

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta-scf.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules siesta-scf)" \
    -RL siesta-scf

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading SIESTA: $(get_c)" \
    -M siesta-trunk.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules siesta-trunk)" \
    -RL siesta-trunk

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading OpenMX: $(get_c)" \
    -M openmx.default/$(get_c) \
    -P "/directory/should/not/exist" \
    -echo "$(echo_modules openmx)" \
    -RL openmx

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
