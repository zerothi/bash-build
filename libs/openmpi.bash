# apt-get libc6-dev
v=3.1.3
add_package -package openmpi \
    http://www.open-mpi.org/software/ompi/v${v:0:3}/downloads/openmpi-$v.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE

# What to check for when checking for installation...
pack_set --install-query $(pack_get --prefix)/bin/mpif90

pack_set --module-requirement zlib
pack_set --module-requirement hwloc
pack_set --module-opt "--set-ENV OMPI_HOME=$(pack_get --prefix)"

# Download zero size scatter/gather patch
if [[ $(vrs_cmp $(pack_get --version) 1.10.1) -eq 0 ]]; then
    o=$(pwd_archives)/openmpi-1.10.1.nbc_copy.patch
    [ ! -e $o ] && \
	dwn_file http://www.student.dtu.dk/~nicpa/packages/openmpi-1.10.1.nbc_copy.patch $o
    pack_cmd "pushd ../"
    pack_cmd "patch -p1 < $o"
    pack_cmd "popd"
fi


tmp_flags=""
[[ -d /opt/torque ]] && tmp_flags="$tmp_flags --with-tm=/opt/torque"
[[ -e /usr/local/include/tm.h ]] && tmp_flags="$tmp_flags --with-tm=/usr/local"
[[ -e /usr/include/slurm/pmi2.h ]] && tmp_flags="$tmp_flags --with-slurm --with-pmi=/usr"
[[ -e /usr/local/include/lsf/lsbatch.h ]] && tmp_flags="$tmp_flags --with-lsf=/usr/local"
[[ -e /usr/include/lsf/lsbatch.h ]] && tmp_flags="$tmp_flags --with-lsf=/usr"
if [[ -d /usr/include/infiniband ]]; then
    tmp_flags="$tmp_flags --with-verbs"
else
    if $(is_host thul surt muspel slid) ; then
        pack_cmd "Cannot compile OpenMPI on this node, infiniband not present."
    fi
fi

if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(pack_get --module-name-requirement flex) $(pack_get --module-name flex)"
fi

# Install commands that it should run
pack_cmd "../configure $tmp_flags" \
	 "--prefix=$(pack_get --prefix)" \
	 "--enable-mpirun-prefix-by-default" \
	 "--with-hwloc=$(pack_get --prefix hwloc)" \
	 "--with-zlib=$(pack_get --prefix zlib)" \
	 "--enable-mpi-thread-multiple" \
	 "--enable-mpi-cxx"

# Fix for the GNU-compiler (it just removes erroneous library linkers)
pack_cmd "sed -i -e '/postdeps/{s:-l ::gi}' libtool"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > tmp.test 2>&1"
pack_set_mv_test tmp.test
pack_cmd "make install"



if [[ $(pack_installed flex) -eq 1 ]] ; then
    pack_cmd "module unload $(pack_get --module-name flex) $(pack_get --module-name-requirement flex)"
fi


new_build --name internal-openmpi \
    --installation-path $(build_get --ip)/$(pack_get --package)/$(pack_get --version) \
    --module-path $(build_get -mp)-openmpi \
    --build-path $(build_get -bp) \
    --build-module-path "$(build_get -bmp)" \
    --build-installation-path "$(build_get -bip)" \
    --source $(build_get --source) \
    $(list -p '--default-module ' $(build_get --default-module) openmpi)
