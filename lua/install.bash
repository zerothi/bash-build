
source_pack lua/lua.bash

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n $(pack_get --alias).$(pack_get --version) \
    -W "Nick R. Papior script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

tmp=$(pack_get --version lua)
lua_V=$(str_version -1 $tmp).$(str_version -2 $tmp)

source_pack lua/rocks.bash
source_pack lua/filesystem.bash
source_pack lua/posix.bash
source_pack lua/mathx.bash
source_pack lua/strip.bash
source_pack lua/complex.bash
source_pack lua/penlight.bash
source_pack lua/peg.bash
source_pack lua/lmod.bash

