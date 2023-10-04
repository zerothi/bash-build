# apt-get libc6-dev
v=4.1.6
add_package -package openmpi \
    http://www.open-mpi.org/software/ompi/v${v:0:3}/downloads/openmpi-$v.tar.bz2

pack_set -s $BUILD_DIR -s $MAKE_PARALLEL -s $IS_MODULE -s $CRT_DEF_MODULE

# What to check for when checking for installation...
pack_set -install-query $(pack_get -prefix)/bin/mpif90

pack_set -module-requirement zlib
if [[ $(vrs_cmp $(pack_get -version) 3) -eq 0 ]]; then
    pack_set -module-requirement hwloc[1]
else
    pack_set -module-requirement hwloc
fi
pack_set -module-opt "-set-ENV OMPI_HOME=$(pack_get -prefix)"
pack_set -module-opt "-set-ENV MPICC=mpicc"
pack_set -module-opt "-set-ENV CMAKE_C_COMPILER=mpicc"
pack_set -module-opt "-set-ENV MPICXX=mpicxx"
pack_set -module-opt "-set-ENV CMAKE_CXX_COMPILER=mpicxx"
pack_set -module-opt "-set-ENV MPIF77=mpif77"
pack_set -module-opt "-set-ENV MPIF90=mpif90"
pack_set -module-opt "-set-ENV MPIFC=mpifort"
pack_set -module-opt "-set-ENV CMAKE_Fortran_COMPILER=mpifort"
# We want to make it easy to create compiler flags for cmake-builds
#pack_set -module-opt "-set-ENV MPI_CMAKE=\"'-DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx -DCMAKE_Fortran_COMPILER=mpifort'\""


# Download zero size scatter/gather patch
if [[ $(vrs_cmp $(pack_get -version) 1.10.1) -eq 0 ]]; then
    o=$(pwd_archives)/openmpi-1.10.1.nbc_copy.patch
    [ ! -e $o ] && \
	dwn_file http://www.student.dtu.dk/~nicpa/packages/openmpi-1.10.1.nbc_copy.patch $o
    pack_cmd "pushd ../"
    pack_cmd "patch -p1 < $o"
    pack_cmd "popd"
elif [[ $(vrs_cmp $(pack_get -version) 4.0.4) -eq 0 ]]; then
    pack_cmd "sed -i -e 's:\(name.vpid = vpid\);:\1++;:' ../orte/mca/rmaps/base/rmaps_base_ranking.c"
fi

tmp_flags=""
[[ -d /opt/torque ]] && tmp_flags="$tmp_flags --with-tm=/opt/torque"
[[ -e /usr/local/include/tm.h ]] && tmp_flags="$tmp_flags --with-tm=/usr/local"
[[ -e /usr/include/slurm/pmi2.h ]] && tmp_flags="$tmp_flags --with-slurm --with-pmi=/usr"
[[ -e /usr/local/include/lsf/lsbatch.h ]] && tmp_flags="$tmp_flags --with-lsf=/usr/local"
# Check env vars
if [[ -n $LSF_BINDIR ]]; then
    # We expect the directory to be of form
    #  ../include
    #  ../*/bin
    tmp=$(dirname $LSF_BINDIR)
    tmp_flags="$tmp_flags --with-lsf=$(dirname $tmp)"
    tmp_flags="$tmp_flags --with-lsf-libdir=$tmp/lib"
    tmp_flags="$tmp_flags --without-tm"
    # for hpc
    tmp_flags="$tmp_flags --with-ofi=no"

else
    [[ -e /usr/include/lsf/lsbatch.h ]] && tmp_flags="$tmp_flags --with-lsf=/usr"
fi

if [[ "$(get_c -n)" == *"debug"* ]]; then
    tmp_flags="$tmp_flags --enable-debug"
fi

if [[ $(vrs_cmp $(pack_get -version) 4) -ge 0 ]]; then
    tmp_flags="$tmp_flags --enable-mpi1-compatibility"
    if [[ $(pack_installed ucx) ]]; then
	# The UCX library also has links to infiniband, so and for
	# 4.X --with-verbs is deprecated in favor of with-ucx
	pack_set -mod-req ucx
	tmp_flags="$tmp_flags --with-ucx=$(pack_get -prefix ucx) --without-verbs"
    elif [[ -d /usr/include/infiniband ]]; then
	tmp_flags="$tmp_flags --with-verbs"
    fi

else
    if [[ -d /usr/include/infiniband ]]; then
	tmp_flags="$tmp_flags --with-verbs"
    else
	if $(is_host thul surt muspel slid) ; then
            pack_cmd "Cannot compile OpenMPI on this node, infiniband not present."
	fi
    fi
fi

if [[ $(pack_installed flex) -eq 1 ]]; then
    pack_cmd "module load $(list -mod-names ++flex)"
fi

# Install commands that it should run
pack_cmd "../configure $tmp_flags" \
	 "--prefix=$(pack_get -prefix)" \
	 "--enable-orterun-prefix-by-default" \
	 "--enable-mpirun-prefix-by-default" \
	 "--with-hwloc=$(pack_get -prefix $(pack_get -mod-req[hwloc]))" \
	 "--with-zlib=$(pack_get -prefix zlib)" \
	 "--enable-mpi-thread-multiple" \
	 "--enable-mpi-cxx"

# Fix for the GNU-compiler (it just removes erroneous library linkers)
pack_cmd "sed -i -e '/postdeps/{s:-l ::gi}' libtool"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make check > openmpi.test 2>&1 || echo forced"
pack_store openmpi.test
pack_cmd "make install"


if [[ $(pack_installed flex) -eq 1 ]] ; then
    pack_cmd "module unload $(list -mod-names ++flex)"
fi


new_build -name _internal-openmpi \
    -installation-path $(build_get -ip)/$(pack_get -package)/$(pack_get -version) \
    -module-path $(build_get -mp)-openmpi \
    -build-path $(build_get -bp) \
    -build-module-path "$(build_get -bmp)" \
    -build-installation-path "$(build_get -bip)" \
    -source $(build_get -source) \
    $(list -p '-default-module ' $(build_get -default-module) openmpi)
