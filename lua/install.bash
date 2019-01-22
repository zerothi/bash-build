
source_pack lua/lua.bash

create_module \
    --module-path $(build_get --module-path[default])-npa \
    -n $(pack_get --alias).$(pack_get --version) \
    -W "Nick R. Papior script for loading $(pack_get --package)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias) 

tmp=$(pack_get --version lua)
lua_V=$(str_version -1 $tmp).$(str_version -2 $tmp)

# Immediately install lua-jit
source_pack lua/luajit.bash

source_pack lua/rocks.bash
source_pack lua/filesystem.bash
source_pack lua/mathx.bash
source_pack lua/xml.bash
source_pack lua/strip.bash
source_pack lua/complex.bash
source_pack lua/penlight.bash
source_pack lua/peg.bash
source_pack lua/ldoc.bash
source_pack lua/lmod.bash

