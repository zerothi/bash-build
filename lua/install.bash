
source_pack lua/lua.bash

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

