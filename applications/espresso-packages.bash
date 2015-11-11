libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt gwl"

case $v in
    
    5.0.3)
libs="bindir libiotk liblapack libblas mods libs libenviron cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt"

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
    dwn_file $pack $o
    pack_cmd "cp $o archive/$(basename ${pack:10})"
    pack_cmd "tar xfz archive/$(basename ${pack:10})"

done

pack_cmd "mv PWgui-5.0.2 PWgui"

# Patch it...
pack_cmd "pushd ../"
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-espresso-5.0.2-5.0.3.diff
dwn_file http://www.qe-forge.org/gf/download/frsrelease/128/435/espresso-5.0.2-5.0.3.diff $o
pack_cmd "patch -p0 < $o"
pack_cmd "popd"

;; # end of 5.0.3
    
    5.0.99)

libs="bindir libiotk liblapack libblas mods libs cp pw pp ph neb tddfpt pwcond ld1 upf xspectra gui acfdt gwl"

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
    dwn_file $pack $o
    pack_cmd "cp $o archive/$(basename ${pack:10})"
    pack_cmd "tar xfz archive/$(basename ${pack:10}) --strip 1"
    
done
pack="http://qe-forge.org/gf/download/frsrelease/116/408/PWgui-5.0.2.tgz"
o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename ${pack:10})
dwn_file $pack $o
pack_cmd "cp $o archive/$(basename ${pack:10})"
pack_cmd "tar xfz archive/$(basename ${pack:10})"

pack_cmd "mv PWgui-5.0.2 PWgui-5.0.1"

;; # end of 5.0.99

    5.1)

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
    dwn_file http://files.qe-forge.org/index.php?file=$pack $o
    pack_cmd "cp $o archive/$pack"
    pack_cmd "tar xfz archive/$pack"
    
done

;; # end of 5.1

    5.1.1)

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
    dwn_file http://qe-forge.org/gf/download/frsrelease/173/$pack $o
    pack=$(basename $pack)

    pack_cmd "cp $o archive/$pack"
    pack_cmd "tar xfz archive/$pack"
    
done
;; # end of 5.1.1

    5.1.2)
    
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
    dwn_file http://qe-forge.org/gf/download/frsrelease/185/$pack $o
    pack=$(basename $pack)

    pack_cmd "cp $o archive/$pack"
    pack_cmd "tar xfz archive/$pack"
    
done

;; # end of 5.1.1

    5.2.1)
    
for pack in \
    845/GWW-$v.tar.gz \
	843/atomic-$v.tar.gz \
	846/pwcond-$v.tar.gz \
	848/neb-$v.tar.gz \
	849/PHonon-$v.tar.gz \
	844/tddfpt-$v.tar.gz \
	847/xspectra-$v.tar.gz \
	850/PWgui-$v.tar.gz \
	do
    o=$(pwd_archives)/$(pack_get --package)-$(pack_get --version)-$(basename $pack)
    dwn_file http://qe-forge.org/gf/download/frsrelease/199/$pack $o
    pack=$(basename $pack)
    
    pack_cmd "cp $o archive/$pack"
    pack_cmd "tar xfz archive/$pack"
    
done

;; # end of 5.2.1
    
esac
