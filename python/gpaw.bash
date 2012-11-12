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
    pack_set --module-requirement atlas \
	--module-requirement scalapack
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

# Add the installation of the gpaw setups
for v in 0.5.3574 0.6.6300 0.8.7929 0.9.9672 ; do
    
    tmp=$(pack_get --alias $(get_parent))-$(pack_get --version $(get_parent))
    add_package http://wiki.fysik.dtu.dk/gpaw-files/gpaw-setups-$v.tar.gz
    
    pack_set -s $IS_MODULE
    
    pack_set --install-prefix $(get_installation_path)/$(pack_get --alias)/$(pack_get --version)
    
    pack_set --module-name $(pack_get --package)/$(pack_get --version)
    
    pack_set --install-query $(pack_get --install-prefix)/
    pack_set --command "mkdir -p $(pack_get --install-prefix)"
    pack_set --command "cp -r ./* $(pack_get --install-prefix)/"
    
    pack_install
done
