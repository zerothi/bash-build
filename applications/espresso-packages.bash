libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt gwl"

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

    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename ${pack:10})
    mywget $pack $o
    pack_set --command "cp $o archive/$(basename ${pack:10})"
    pack_set --command "tar xfz archive/$(basename ${pack:10})"

done

pack_set --command "mv PWgui-5.0.2 PWgui"

# Patch it...
pack_set --command "pushd ../"
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-espresso-5.0.2-5.0.3.diff
mywget http://www.qe-forge.org/gf/download/frsrelease/128/435/espresso-5.0.2-5.0.3.diff $o
pack_set --command "patch -p0 < $o"
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
    
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename ${pack:10})
    mywget $pack $o
    pack_set --command "cp $o archive/$(basename ${pack:10})"
    pack_set --command "tar xfz archive/$(basename ${pack:10}) --strip 1"
    
done
pack="http://qe-forge.org/gf/download/frsrelease/116/408/PWgui-5.0.2.tgz"
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename ${pack:10})
mywget $pack $o
pack_set --command "cp $o archive/$(basename ${pack:10})"
pack_set --command "tar xfz archive/$(basename ${pack:10})"

pack_set --command "mv PWgui-5.0.2 PWgui-5.0.1"

libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt gwl"

elif [ "$v" = "5.1" ]; then

libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt"
    
for pack in \
    PHonon-5.1.tar.gz \
    neb-5.1.tar.gz \
    xspectra-5.1.tar.gz \
    tddfpt-5.1.tar.gz \
    PWgui-5.1.tar.gz \
    atomic-5.1.tar.gz \
    pwcond-5.1.tar.gz
do
    
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$pack
    mywget http://files.qe-forge.org/index.php?file=$pack $o
    pack_set --command "cp $o archive/$pack"
    pack_set --command "tar xfz archive/$pack"
    
done

elif [ "$v" = "5.1.1" ]; then

libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra acfdt gwl"
    
for pack in \
    651/PHonon-$v.tar.gz \
    652/neb-$v.tar.gz \
    649/xspectra-$v.tar.gz \
    648/tddfpt-$v.tar.gz \
    653/GWW-$v.tar.gz \
    647/atomic-$v.tar.gz \
    650/pwcond-$v.tar.gz
do
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename $pack)
    mywget http://qe-forge.org/gf/download/frsrelease/173/$pack $o
    pack=$(basename $pack)

    pack_set --command "cp $o archive/$pack"
    pack_set --command "tar xfz archive/$pack"
    
done

elif [ "$v" = "5.1.2" ]; then
    
for pack in \
    755/PHonon-$v.tar.gz \
    760/neb-$v.tar.gz \
    757/xspectra-$v.tar.gz \
    758/tddfpt-$v.tar.gz \
    754/GWW-$v.tar.gz \
    759/PWgui-$v.tar.gz \
    752/atomic-$v.tar.gz \
    756/pwcond-$v.tar.gz
do
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename $pack)
    mywget http://qe-forge.org/gf/download/frsrelease/185/$pack $o
    pack=$(basename $pack)

    pack_set --command "cp $o archive/$pack"
    pack_set --command "tar xfz archive/$pack"
    
done

fi
