v=6.1.0.31

for c in gfortran ; do
    
add_package --build vendor \
    --version $v \
    --alias acml-install \
    --package acml \
    --directory ./ \
    http://www.student.dtu.dk/~nicpa/packages/acml-$v-$c-64bit.tgz

pack_set --install-query $(pack_get --prefix)/${c}64

pack_cmd "mkdir -p $(pack_get --prefix)"
pack_cmd "mv Doc ${c}64* ReleaseNotes util $(pack_get --prefix)/"

pack_cmd "rm ACML-EULA.txt NOTICE.txt"
pack_cmd "chmod a+x $(pack_get --prefix)/util/cpuid.exe"

# We need to create all the different modules...
for directive in nothing fma4 ; do
[ "$directive" == "fma4" ] && continue
[ "$directive" == "nothing" ] && directive=""
for mp in nothing mp ; do
[ "$mp" == "nothing" ] && mp=""

tmp=${c//gfortran/gnu}
tmp=${tmp//ifort/intel}
[ -n "$directive" ] && tmp=${tmp}-$directive
[ -n "$mp" ] && tmp=${tmp}-$mp

add_package --build vendor \
    --version $v \
    --package acml-$tmp \
    --directory ./ \
    acml.local

pack_set -s $IS_MODULE

# Add ./util dir to path
pack_set --module-opt \
    "--prepend-ENV PATH=$(pack_get --prefix acml-install)/util"

# Create custom ACML_DIR env-variable
tmp=${c}64
[ -n "$directive" ] && tmp=${tmp}_$directive
[ -n "$mp" ] && tmp=${tmp}_$mp
pack_set --prefix $(pack_get --prefix acml-install)/$tmp

pack_set --module-opt "--set-ENV ACML_DIR=$(pack_get --prefix)"

pack_set --lua-family acml

pack_set --install-query /directory/does/not/exist
tmp=${c//gfortran/gnu}
tmp=${tmp//ifort/intel}
[ -n "$directive" ] && tmp="${tmp}-$directive"
[ -n "$mp" ] && tmp="${tmp}-$mp"
pack_set --module-name acml/$v/$tmp

done # mp
done # directive

done # compiler

