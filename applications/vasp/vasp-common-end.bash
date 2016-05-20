pack_cmd "cd vasp.5.lib"

tmp=makefile.linux_npa_vasp_lib
pack_cmd "wget http://www.student.dtu.dk/~nicpa/packages/makefile.linux_npa_vasp_lib_$v -O $tmp"
pack_cmd "sed -i -e 's:include \(.*\):include \1\n\
CPP = gcc -E -P -C \$*.F >\$*.f\n\
FC  = $FC\n\
FFLAGS = $FCFLAGS\n\
CC  = $CC\n:' $tmp"

pack_cmd "make -f $tmp"

pack_cmd "cd ../vasp.5.3"

tmp=makefile.linux_npa_vasp
pack_cmd "wget http://www.student.dtu.dk/~nicpa/packages/makefile.linux_npa_vasp_$v -O $tmp"

# Prepare the installation directory
pack_cmd "mkdir -p $(pack_get --prefix)/bin"

# Create the make command
function compile_ispin {
    local i=$1 ; shift
    local exe=$1 ; shift
    pack_cmd "sed -i -e 's/ISPIN_SELECT[ ]*=[ ]*[0-2]/ISPIN_SELECT=$i/' pardens.F"
    # Ensure we re-compile pardens
    pack_cmd "rm -f pardens.o"
    pack_cmd "make -f $tmp"
    pack_cmd "cp vasp $(pack_get --prefix)/bin/${exe}_is$i"
    if [[ $i -eq 0 ]]; then
	pack_cmd "pushd $(pack_get --prefix)/bin"
	pack_cmd "ln -fs ${exe}_is0 ${exe}"
	pack_cmd "popd"
    fi
}

# Make commands
for i in 0 1 2 ; do
    compile_ispin $i vasp
done

pack_cmd "make -f $tmp clean"

# Prepare the next installation
pack_cmd "sed -i -e 's:#PLACEHOLDER#.*:CPP += -DNGZhalf :' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vaspNGZhalf
done

pack_cmd "make -f $tmp clean"

# Prepare the next installation
pack_cmd "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vaspGNGZhalf
done

pack_cmd "make -f $tmp clean"

###################### Prepare the TST code ##########################

# First revert to initial setup
pack_cmd "sed -i -e 's:-DNGZhalf.*:-DNPA_PLACEHOLDER:' ../mymakefile"

# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstcode.tar.gz"
pack_cmd "wget http://theory.cm.utexas.edu/code/vtstcode.tgz"
pack_cmd "tar xfz vtstcode.tgz"
pack_cmd "cp -r vtstcode-*/* ./"

# Bugfix for code
pack_cmd "sed -i -e 's:<NBAS>:10000:gi' bbm.F"

# Install module compilations...
pack_cmd "sed -i -e 's:\(CHAIN_FORCE[^\&]*\):\1TSIF, :i' main.F"
pack_cmd "sed -s -i -e 's:[[:space:]]*\(\#[end]*if\):\1:i' chain.F dimer.F"
pack_cmd "sed -i -e 's:\(chain.o\):bfgs.o dynmat.o instanton.o lbfgs.o sd.o cg.o dimer.o bbm.o fire.o lanczos.o neb.o qm.o opt.o \1 :' $tmp"

# Install vtst scripts
# old link: http://theory.cm.utexas.edu/vtsttools/code/vtstscripts.tar.gz"
pack_cmd "wget http://theory.cm.utexas.edu/code/vtstscripts.tgz"
pack_cmd "tar xfz vtstscripts.tgz"
pack_cmd "cp -r vtstscripts-*/* $(pack_get --prefix)/bin/"

######################   end the TST code   ##########################

# Install vasp_tst 
for i in 0 1 2 ; do
    compile_ispin $i vasp_tst
done

pack_cmd "make -f $tmp clean"

# Prepare the next installation
pack_cmd "sed -i -e 's:-DNPA_PLACEHOLDER.*:-DNGZhalf :' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vasp_tstNGZhalf
done

pack_cmd "make -f $tmp clean"

# Prepare the next installation
pack_cmd "sed -i -e 's:NGZhalf:NGZhalf -DwNGZhalf:' ../mymakefile"
for i in 0 1 2 ; do
    compile_ispin $i vasp_tstGNGZhalf
done

pack_cmd "make -f $tmp clean"

unset compile_ispin

# Copy over the vdw_kernel
tmp=vdw_kernel.bindat
pack_cmd "mkdir -p $(pack_get --prefix)/data"
pack_cmd "cp $tmp $(pack_get --prefix)/data/$tmp"
# Add an ENV-flag for the kernel to be copied
pack_set --module-opt "--set-ENV VASP_VDWKERNEL=$(pack_get --prefix)/data/$tmp"

# Ensure that the group is correctly set
tmp="$(pack_get --prefix)/bin"
if $(is_host n-) ; then
    pack_cmd "chmod o-rwx $tmp/vasp*"
    pack_cmd "chgrp nanotech $tmp/vasp*"
elif $(is_host surt muspel slid a0 b0 c0 d0 g0 m0 n0 q0 p0 a1 b1 c1 d1 g1 m1 n1 q1 p1) ; then
    pack_cmd "chmod o-rwx $tmp/vasp*"
    pack_cmd "chgrp vasp $tmp/vasp*"
fi
