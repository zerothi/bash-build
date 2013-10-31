for pack in \
    http://qe-forge.org/gf/download/frsrelease/116/404/neb-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/408/PWgui-5.0.2.tgz \
    http://qe-forge.org/gf/download/frsrelease/116/410/XSpectra-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/405/PHonon-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/404/neb-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/402/atomic-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/407/pwcond-5.0.2.tar.gz \
    http://qe-forge.org/gf/download/frsrelease/116/409/tddfpt-5.0.2.tar.gz 
do
    
    pack_set --command "wget $pack -O archive/$(basename ${pack:10})"
    pack_set --command "tar xvfz archive/$(basename ${pack:10})"

done

pack_set --command "mv PWgui-5.0.2 PWgui"