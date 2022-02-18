for v in 1812 1906 2112
do
add_package -package openfoam \
	    https://dl.openfoam.com/source/v$v/OpenFOAM-v$v.tgz

pack_set -host-reject $(get_hostname)
pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get --prefix)/bin/OpenFOAM

pack_set -build-mod-req build-tools
pack_set $(list -prefix '-mod-req ' mpi cgal fftw boost scotch hypre petsc-d)


o=$(pwd_archives)/$(pack_get -package)-$(pack_get -version)-ThirdParty-v$v.tgz
dwn_file https://sourceforge.net/projects/openfoamplus/files/v$v/ThirdParty-v$v.tgz $o
pack_cmd "tar xfz $o -C ."

pack_cmd "mv ThirdParty-v$v ThirdParty"
pack_cmd "export WM_THIRD_PARTY_DIR=\$(pwd)/ThirdParty"
pack_cmd "export WM_MPLIB=SYSTEMOPENMPI"


pack_cmd "sed -i -e '/END OF (NORMAL)/i \
SCOTCH_VERSION=scotch-system\n\
export SCOTCH_ARCH_PATH=$(pack_get -prefix scotch)\n\
' etc/config.sh/scotch"

pack_cmd "sed -i -e '/END OF (NORMAL)/i \
METIS_VERSION=metis-system\n\
export METIS_ARCH_PATH=$(pack_get -prefix metis)\n\
' etc/config.sh/metis"

pack_cmd "sed -i -e '/END OF (NORMAL)/i \
fftw_version=fftw-system\n\
export FFTW_ARCH_PATH=$(pack_get -prefix fftw)\n\
' etc/config.sh/FFTW"

pack_cmd "sed -i -e '/END OF (NORMAL)/i \
petsc_version=petsc-system\n\
export PETSC_ARCH_PATH=$(pack_get -prefix petsc-d)\n\
' etc/config.sh/petsc"

pack_cmd "sed -i -e '/END OF (NORMAL)/i \
hypre_version=hypre-system\n\
export HYRPE_ARCH_PATH=$(pack_get -prefix hypre)\n\
' etc/config.sh/hypre"

if $(is_c gnu) ; then
    pack_cmd "sed -i -e '/END OF (NORMAL)/i \
export MPFR_ARCH_PATH=$(pack_get -prefix gcc[$(get_c -v)])\n\
export GMP_ARCH_PATH=$(pack_get -prefix gcc[$(get_c -v)])\n\
' etc/config.sh/CGAL"
fi

    pack_cmd "sed -i -e '/END OF (NORMAL)/i \
boost_version=boost-system\n\
cgal_version=cgal-system\n\
export BOOST_ARCH_PATH=$(pack_get -prefix boost)\n\
export CGAL_ARCH_PATH=$(pack_get -prefix cgal)\n\
' etc/config.sh/CGAL"

pack_cmd "source etc/bashrc"
# Override with local settings
pack_cmd "export WM_NCOMPPROCS=$NPROCS"
pack_cmd "export FOAM_VERBOSE=true"

# Check system
pack_cmd "foamSystemCheck"
# Run make
pack_cmd "./Allwmake"

pack_cmd "asotneuhsnaotehusnath"

done
