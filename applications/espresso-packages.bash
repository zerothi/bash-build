if [ "$v" = "5.0.3" ]; then

for pack in \
    http://qe-forge.org/gf/download/frsrelease/116/404/neb-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/408/PWgui-5.0.2.tgz \
    http://qe-forge.org/gf/download/frsrelease/116/410/XSpectra-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/405/PHonon-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/402/atomic-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/407/pwcond-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/409/tddfpt-5.0.2.tar.gz 
do
    
    pack_set --command "wget $pack -O archive/$(basename ${pack:10})"
    pack_set --command "tar xfz archive/$(basename ${pack:10})"

done

pack_set --command "mv PWgui-5.0.2 PWgui"

# Patch it...
pack_set --command "pushd ../"
pack_set --command "wget http://www.qe-forge.org/gf/download/frsrelease/128/435/espresso-5.0.2-5.0.3.diff"
pack_set --command "patch -p0 < espresso-5.0.2-5.0.3.diff"
pack_set --command "rm espresso-5.0.2-5.0.3.diff"
pack_set --command "popd"

libs="bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt"

elif [ "$v" = "5.0.99" ]; then
    
for pack in \
    http://qe-forge.org/gf/download/frsrelease/151/520/NEB-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/525/XSpectra-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/524/GWW-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/521/PHonon-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/522/TDDFPT-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/526/atomic-5.0.99.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/151/523/PWCOND-5.0.99.tar.gz
do
    
    opack=$(basename ${pack:10})
    pack_set --command "wget $pack -O archive/$opack"
    pack_set --command "tar xfz archive/$opack --strip 1"

done
pack="http://qe-forge.org/gf/download/frsrelease/116/408/PWgui-5.0.2.tgz"
opack=$(basename ${pack:10})
pack_set --command "wget $pack -O archive/$opack"
pack_set --command "tar xfz archive/$opack"

pack_set --command "mv PWgui-5.0.2 PWgui-5.0.1"

libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt gwl"

fi