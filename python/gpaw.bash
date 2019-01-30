for v in 1.5.1 ; do
add_package --archive gpaw-$v.tar.gz \
    https://gitlab.com/gpaw/gpaw/repository/archive.tar.gz?ref=$v

pack_set -s $IS_MODULE

pack_set -directory gpaw-$v-*

pack_set --module-opt "--lua-family gpaw"

if [[ $(vrs_cmp $pV 3) -ge 0 ]]; then
    hdf=False
else
    hdf=True
    pack_set --module-requirement hdf5
fi

pack_set --install-query $(pack_get --prefix)/bin/gpaw-python

pack_set --module-requirement mpi \
    --module-requirement matplotlib \
    --module-requirement libxc

if [[ $(vrs_cmp $v 0.11) -ge 0 ]]; then
    pack_set --module-requirement ase
else
    doerr "$(pack_get --package)" "Could not determine needed ASE interface"
fi

# First we need to fix gpaw compilation
pack_cmd "sed -i 's/-Wl,-R/-Wl,-rpath=/g' config.py"
pack_cmd "sed -i 's/-R/-Wl,-rpath=/g' config.py"
pack_cmd "sed -i \"s:cfgDict.get('BLDLIBRARY:cfgDict.get('LIBDIR')+os.sep+cfgDict.get('BLDLIBRARY:\" config.py"

# Check for Intel MKL or not
file=customize.py
pack_cmd "echo '#' > $file"


if $(is_c intel) ; then
    pack_cmd "sed -i '1 a\
compiler = \"$CC $pCFLAGS $MKL_LIB -mkl=sequential\"\n\
mpicompiler = \"$MPICC $pCFLAGS $MKL_LIB\"\n\
libraries = [\"mkl_scalapack_lp64\",\"mkl_blacs_openmpi_lp64\",\"mkl_lapack95_lp64\",\"mkl_blas95_lp64\"]\n\
extra_link_args = [\"$MKL_LIB\",\"-mkl=sequential\"]\n\
platform_id = \"$(get_hostname)\"\n' $file"

elif $(is_c gnu) ; then
    pack_cmd "sed -i '1 a\
compiler = \"$CC $pCFLAGS \"\n\
mpicompiler = \"$MPICC $pCFLAGS \"\n' $file"
    pack_set --module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set --module-requirement $la
    tmp="$(pack_get -lib $la)"
    # Remove -l in front of libraries
    tmp=${tmp//-l/}
    tmp_ld="$(list -c 'pack_get -LD' +$la)"
    # We might as well use the python power here
    pack_cmd "sed -i '$ a\
library_dirs += \"$(pack_get --LD scalapack) $tmp_ld\".split()\n\
runtime_library_dirs += \"$(pack_get --LD scalapack) $tmp_ld\".split()\n\
libraries = \"scalapack $tmp gfortran \".split()\n' $file"

else
    doerr gpaw "Could not determine compiler..."

fi

tmp="$(list --prefix ,\" --suffix /include\" --loop-cmd 'pack_get --prefix' $(pack_get --mod-req-path))"

pack_cmd "sed -i '$ a\
library_dirs += [\"$(pack_get --LD libxc)\"]\n\
runtime_library_dirs += [\"$(pack_get --LD libxc)\"]\n\
include_dirs += [\"$(pack_get --prefix libxc)/include\"]\n\
libraries += [\"xc\"]\n\
include_dirs += [\"$(pack_get --prefix mpi)/include\"]\n\
extra_compile_args = \"$pCFLAGS -std=c99\".split(\" \")\n\
mpi_runtime_library_dirs += [\"$(pack_get --LD mpi)\"]\n\
mpi_runtime_library_dirs += [\"$(pack_get --LD hdf5)\"]\n\
scalapack = True\n\
\n\
if scalapack:\n\
    define_macros += [(\"GPAW_NO_UNDERSCORE_CBLACS\", \"1\")]\n\
    define_macros += [(\"GPAW_NO_UNDERSCORE_CSCALAPACK\", \"1\")]\n\
\n\
hdf5 = $hdf\n\
library_dirs += [\"$(pack_get --LD hdf5)\"]\n\
runtime_library_dirs += [\"$(pack_get --LD hdf5)\"]\n\
libraries += [\"hdf5_hl\",\"hdf5\"]\n\
library_dirs += [\"$(pack_get --LD zlib)\"]\n\
runtime_library_dirs += [\"$(pack_get --LD zlib)\"]\n\
libraries += [\"z\"]\n\
extra_link_args += map(lambda s: \"-Wl,-rpath=\"+s,runtime_library_dirs)\n\
\n\
# Add all directories for inclusion\n\
include_dirs += [${tmp:2}]' $file"
unset hdf

# Add python directory
pack_cmd "sed -i '$ a\
library_dirs += [\"$(pack_get --LD $(get_parent))\"]\n\
runtime_library_dirs += [\"$(pack_get --LD $(get_parent))\"]\n\
' $file"

pack_cmd "unset LDFLAGS"

pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

# Copy the customize.py file with
pack_cmd "cp customize.py $(pack_get --prefix)/"

add_test_package gpaw.exec.parallel

pack_set --host-reject $(get_hostname)
# We need the setups for the tests
pack_set --mod-req gpaw-setups
pack_cmd "unset LDFLAGS"
pack_cmd "$(get_parent_exec) \$(which gpaw-test) 2>&1 > gpaw.serial ; echo 'Forced'"
pack_set_mv_test gpaw.serial
pack_cmd "gpaw-python \$(which gpaw-test) 2>&1 > gpaw.exec.serial ; echo 'Forced'"
pack_set_mv_test gpaw.exec.serial
pack_cmd "mpirun -np 2 gpaw-python \$(which gpaw-test) 2>&1 > gpaw.exec.parallel ; echo 'Forced'"
pack_set_mv_test gpaw.exec.parallel

done
