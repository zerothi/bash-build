[ "x${pV:0:1}" == "x3" ] && return 0

for v in 0.9.0.8965 ; do
add_package https://wiki.fysik.dtu.dk/gpaw-files/gpaw-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject "ntch-2857"

pack_set --prefix-and-module $(pack_get --alias)/$(pack_get --version)/$IpV/$(get_c)

pack_set --install-query $(pack_get --install-prefix)/bin/gpaw

pack_set --module-requirement openmpi \
    --module-requirement ase[3.6] \
    --module-requirement matplotlib \
    --module-requirement h5py

# Check for Intel MKL or not
file=$(pack_get --alias)-$(pack_get --version).site.cfg
if $(is_c intel) ; then
    cat << EOF > $file
compiler = '$CC $CFLAGS $MKL_LIB -mkl=sequential'
mpicompiler = '$MPICC $CFLAGS $MKL_LIB'
libraries = ['mkl_scalapack_lp64','mkl_blacs_openmpi_lp64','mkl_lapack95_lp64','mkl_blas95_lp64']
extra_link_args = ['$MKL_LIB','-mkl=sequential']
platform_id = "Xeon"
EOF

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack
    cat << EOF > $file
compiler = '$CC $CFLAGS '
mpicompiler = '$MPICC $CFLAGS '
library_dirs += ['$(pack_get --install-prefix atlas)/lib']
EOF
    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	cat << EOF >> $file
library_dirs += ['$(pack_get --install-prefix blas)/lib']
library_dirs += ['$(pack_get --install-prefix lapack)/lib']
libraries = ['scalapack','lapack','blas']
EOF
    else
	pack_set --module-requirement lapack
	cat << EOF >> $file
library_dirs += ['$(pack_get --install-prefix atlas)/lib']
libraries = ['scalapack','lapack','f77blas','cblas','atlas']
EOF
    fi
fi

tmp="$(list --prefix ,\' --suffix /include\' --loop-cmd 'pack_get --install-prefix' $(pack_get --module-requirement))"
cat << EOF >> $file
include_dirs += ['$(pack_get --install-prefix openmpi)/include']
extra_compile_args = '$CFLAGS -std=c99'.split(' ')
scalapack = True

if scalapack:
    define_macros += [('GPAW_NO_UNDERSCORE_CBLACS', '1')]
    define_macros += [('GPAW_NO_UNDERSCORE_CSCALAPACK', '1')]

hdf5 = True
library_dirs += ['$(pack_get --install-prefix hdf5)/lib']
libraries += ['hdf5_hl','hdf5']
library_dirs += ['$(pack_get --install-prefix zlib)/lib']
libraries += ['z']

# Add all directories for inclusion
include_dirs += [${tmp:2}]
EOF


pack_set --command "cp $(pwd)/$file customize.py"
pack_set --command "rm $(pwd)/$file"
pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
