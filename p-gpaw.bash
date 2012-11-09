tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package https://wiki.fysik.dtu.dk/gpaw-files/gpaw-0.9.0.8965.tar.gz

pack_set -s $IS_MODULE

pack_set --install-prefix \
    $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name \
    $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/gpaw

pack_set --module-requirement openmpi \
    --module-requirement $(get_parent) \
    --module-requirement numpy \
    --module-requirement scipy \
    --module-requirement matplotlib

module load $(pack_get --module-name openmpi)

# Check for Intel MKL or not
tmp=$(get_c)
file=$(pack_get --alias)-$(pack_get --version).site.cfg
if [ "${tmp:0:5}" == "intel" ]; then
    cat << EOF > $file
compiler = '$CC $CFLAGS -mkl=sequential'
mpicompiler = '$MPICC $CFLAGS '
libraries = ['mkl_scalapack_lp64','mkl_blacs_openmpi_lp64']
extra_link_args = ['-mkl=sequential']
platform_id = "Xeon"
EOF

elif [ "${tmp:0:3}" == "gnu" ]; then
    module load $(pack_get --module-name atlas)
    module load $(pack_get --module-name scalapack)
    cat << EOF > $file
compiler = '$CC $CFLAGS '
mpicompiler = '$MPICC $CFLAGS '
library_dirs += ['$(pack_get --install-prefix atlas)/lib']
library_dirs += ['$(pack_get --install-prefix scalapack)/lib']
libraries = ['scalapack','lapack_atlas','f77blas','cblas','atlas']
EOF

fi

cat << EOF >> $file
include_dirs += ['$(pack_get --install-prefix openmpi)/include']
extra_compile_args = '$CFLAGS -std=c99'.split(' ')
scalapack = True

if scalapack:
    define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
    define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]

hdf5 = True
include_dirs += ['$(pack_get --install-prefix hdf5)/include']
library_dirs += ['$(pack_get --install-prefix hdf5)/lib']
libraries += ['hdf5_hl','hdf5']
library_dirs += ['$(pack_get --install-prefix zlib)/lib']
libraries += ['z']

EOF


pack_set --command "cp $(pwd)/$file customize.py"
pack_set --command "rm $(pwd)/$file"
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

pack_install

module unload $(pack_get --module-name openmpi)

# Add the installation of the gpaw setups
tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
add_package http://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-0.9.9672.tar.gz

pack_set -s $IS_MODULE

pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)/$tmp/$(get_c)

pack_set --module-name $(pack_get --package)/$(pack_get --version)/$tmp/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/

pack_install
