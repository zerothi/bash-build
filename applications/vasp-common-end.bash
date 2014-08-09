pack_set --command "cd vasp.5.lib"

tmp=makefile.linux_npa_vasp_lib
pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/makefile.linux_npa_vasp_lib_$v -O $tmp"
pack_set --command "sed -i -e 's:include \(.*\):include \1\n\
CPP = gcc -E -P -C \$*.F >\$*.f\n\
FC  = $FC\n\
FFLAGS = $FCFLAGS\n\
CC  = $CC\n:' $tmp"

pack_set --command "make -f $tmp"

pack_set --command "cd ../vasp.5.3"

tmp=makefile.linux_npa_vasp
pack_set --command "wget http://www.student.dtu.dk/~nicpa/packages/makefile.linux_npa_vasp_$v -O $tmp"

# Prepare the installation directory
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"

# Make commands
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGZhalf :' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspNGZhalf"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vaspGNGZhalf"
pack_set --command "make -f $tmp clean"

###################### Prepare the TST code ##########################

# First revert to initial setup
pack_set --command "sed -i -e 's:-DNGZhalf.*:-DNPA_PLACEHOLDER:' ../mymakefile"

# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstcode.tar.gz"
pack_set --command "wget http://theory.cm.utexas.edu/code/vtstcode.tgz"
pack_set --command "tar xfz vtstcode.tgz"
pack_set --command "cp -r vtstcode-*/* ./"

# Bugfix for code
pack_set --command "sed -i -e 's:<NBAS>:10000:gi' bbm.F"

# Install module compilations...
pack_set --command "sed -i -e 's:\(CHAIN_FORCE[^\&]*\):\1TSIF, :i' main.F"
pack_set --command "sed -s -i -e 's:[[:space:]]*\(\#[end]*if\):\1:i' chain.F dimer.F"
pack_set --command "sed -i -e 's:\(chain.o\):bfgs.o dynmat.o instanton.o lbfgs.o sd.o cg.o dimer.o bbm.o fire.o lanczos.o neb.o qm.o opt.o \1 :' $tmp"

# Install vtst scripts
# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstscripts.tar.gz"
pack_set --command "wget http://theory.cm.utexas.edu/code/vtstscripts.tgz"
pack_set --command "tar xfz vtstscripts.tgz"
pack_set --command "cp -r vtstscripts-*/* $(pack_get --install-prefix)/bin/"

######################   end the TST code   ##########################

# Install vasp_tst 
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp_tst"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:-DNPA_PLACEHOLDER.*:-DNGZhalf :' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp_tstNGZhalf"
pack_set --command "make -f $tmp clean"

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
pack_set --command "make -f $tmp"
pack_set --command "cp vasp $(pack_get --install-prefix)/bin/vasp_tstGNGZhalf"
pack_set --command "make -f $tmp clean"

# Copy over the vdw_kernel
vdw=vdw_kernel.bindat
pack_set --command "mkdir -p $(pack_get --install-prefix)/data"
pack_set --command "cp $vdw $(pack_get --install-prefix)/data/$vdw"
# Add an ENV-flag for the kernel to be copied
pack_set --module-opt "--set-ENV VASP_VDWKERNEL=$(pack_get --install-prefix)/data/$vdw"

# Ensure that the group is correctly set
tmp="$(pack_get --install-prefix)/bin"
if $(is_host n-) ; then
    pack_set --command "chmod o-rwx $tmp/vasp*"
    pack_set --command "chgrp nanotech $tmp/vasp*"
elif $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 q0 p0 a1 b1 c1 d1 g1 m1 n1 q1 p1) ; then
    pack_set --command "chmod o-rwx $tmp/vasp*"
    pack_set --command "chgrp vasp $tmp/vasp*"
fi

pack_install

create_module \
    --module-path $(build_get --module-path)-npa-apps \
    -n "Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version)/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-L ' $(pack_get --module-requirement)) \
    -L $(pack_get --alias)
