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

# Create the make command
function compile_ispin {
    local i=$1 ; shift
    local exe=$1 ; shift
    pack_set --command "sed -i -e 's/ISPIN_SELECT[ ]*=[ ]*[0-2]/ISPIN_SELECT=$i/' pardens.F"
    pack_set --command "make -f $tmp"
    pack_set --command "cp vasp $(pack_get --install-prefix)/bin/${exe}_is$i"
    pack_set --command "make -f $tmp clean"
    if [ $i -eq 0 ]; then
	pack_set --command "pushd $(pack_get --install-prefix)/bin"
	pack_set --command "ln -s ${exe}_is0 ${exe}"
	pack_set --command "popd"
    fi
}

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp
done

# Prepare the next installation
pack_set --command "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGZhalf :' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vaspNGZhalf
done

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vaspGNGZhalf
done

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
for i in 0 1 2 ; do
    compile_ispin $i vasp_tst
done

# Prepare the next installation
pack_set --command "sed -i -e 's:-DNPA_PLACEHOLDER.*:-DNGZhalf :' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vasp_tstNGZhalf
done

# Prepare the next installation
pack_set --command "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vasp_tstGNGZhalf
done

unset compile_ispin

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
