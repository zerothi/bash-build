[ "x${pV:0:1}" == "x3" ] && return 0

for v in 0.9.0.8965 ; do
add_package https://wiki.fysik.dtu.dk/gpaw-files/gpaw-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --host-reject "ntch-2857"

pack_set --module-opt "--lua-family gpaw"

pack_set --install-query $(pack_get --install-prefix)/bin/gpaw

pack_set --module-requirement openmpi \
    --module-requirement ase[3.6] \
    --module-requirement matplotlib \
    --module-requirement h5py

# Check for Intel MKL or not
file=customize.py
pack_set --command "echo '#' > $file"

if $(is_c intel) ; then
    pack_set --command "sed -i '1 a\
compiler = \"$CC $CFLAGS $MKL_LIB -mkl=sequential\"\n\
mpicompiler = \"$MPICC $CFLAGS $MKL_LIB\"\n\
libraries = [\"mkl_scalapack_lp64\",\"mkl_blacs_openmpi_lp64\",\"mkl_lapack95_lp64\",\"mkl_blas95_lp64\"]\n\
extra_link_args = [\"$MKL_LIB\",\"-mkl=sequential\"]\n\
platform_id = \"Xeon\"' $file"

elif $(is_c gnu) ; then
    pack_set --module-requirement scalapack
    pack_set --command "sed -i '1 a\
compiler = \"$CC $CFLAGS \"\n\
mpicompiler = \"$MPICC $CFLAGS \"\n\
library_dirs += [\"$(pack_get --install-prefix atlas)/lib\"]' $file"

    if [ $(pack_installed atlas) -eq 1 ] ; then
	pack_set --module-requirement atlas
	pack_set --command "sed -i '$ a\
library_dirs += [\"$(pack_get --install-prefix blas)/lib\"]\n\
library_dirs += [\"$(pack_get --install-prefix lapack)/lib\"]\n\
libraries = [\"scalapack\",\"lapack\",\"blas\"]' $file"

    else
	pack_set --module-requirement lapack
	pack_set --command "sed -i '$ a\
library_dirs += [\"$(pack_get --install-prefix atlas)/lib\"]\n\
libraries = [\"scalapack\",\"lapack\",\"f77blas\",\"cblas\",\"atlas\"]' $file"

    fi
fi

tmp="$(list --prefix ,\" --suffix /include\" --loop-cmd 'pack_get --install-prefix' $(pack_get --module-paths-requirement))"

pack_set --command "sed -i '$ a\
include_dirs += [\"$(pack_get --install-prefix openmpi)/include\"]\n\
extra_compile_args = \"$CFLAGS -std=c99\".split(\" \")\n\
scalapack = True\n\
\n\
if scalapack:\n\
    define_macros += [(\"GPAW_NO_UNDERSCORE_CBLACS\", \"1\")]\n\
    define_macros += [(\"GPAW_NO_UNDERSCORE_CSCALAPACK\", \"1\")]\n\
\n\
hdf5 = True\n\
library_dirs += [\"$(pack_get --install-prefix hdf5)/lib\"]\n\
libraries += [\"hdf5_hl\",\"hdf5\"]\n\
library_dirs += [\"$(pack_get --install-prefix zlib)/lib\"]\n\
libraries += [\"z\"]\n\
\n\
# Add all directories for inclusion\n\
include_dirs += [${tmp:2}]' $file"

pack_set --command "$(get_parent_exec) setup.py build"
pack_set --command "$(get_parent_exec) setup.py install" \
    --command-flag "--prefix=$(pack_get --install-prefix)"

done
