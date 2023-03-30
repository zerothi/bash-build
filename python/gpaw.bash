for v in 20.10.0 21.6.0 22.8.0 ; do
add_package https://gitlab.com/gpaw/gpaw/-/archive/$v/gpaw-$v.tar.bz2

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

# Not working on py2
[[ ${pV:0:1} -eq 2 ]] && pack_set -host-reject $(get_hostname)

pack_set -module-opt "-lua-family gpaw"

if [[ $(vrs_cmp $pV 3) -ge 0 ]]; then
    hdf=False
else
    hdf=True
    pack_set -module-requirement hdf5
fi

pack_set -install-query $(pack_get -prefix)/bin/gpaw
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

# should work with ELPA, but they are not using the correct version
pack_set $(list -p '-mod-req ' mpi scipy matplotlib libxc fftw ase)

# First we need to fix gpaw compilation
pack_cmd "sed -i -e 's/-Wl,-R/-Wl,-rpath=/g;s/-R/-Wl,-rpath=/g' config.py"
pack_cmd "sed -i -e \"s:cfgDict.get('BLDLIBRARY:cfgDict.get('LIBDIR')+os.sep+cfgDict.get('BLDLIBRARY:\" config.py"

file=$(pack_get -prefix)/siteconfig.py
pack_cmd "echo '#' > $file"

# Check for Intel MKL or not
if $(is_c intel) ; then
    # The clck library path has libutil.so which fucks up things!
    pack_cmd "unset LIBRARY_PATH"

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
    pack_set -module-requirement scalapack

    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$(pack_get -lib $la)"
    # Remove -l in front of libraries
    tmp=${tmp//-l/}
    tmp_ld="$(list -c 'pack_get -LD' +$la)"
    # We might as well use the python power here
    pack_cmd "sed -i '$ a\
library_dirs += \"$(pack_get -LD scalapack) $tmp_ld\".split()\n\
runtime_library_dirs += \"$(pack_get -LD scalapack) $tmp_ld\".split()\n\
libraries = \"scalapack $tmp gfortran \".split()\n' $file"

else
    doerr gpaw "Could not determine compiler..."

fi

tmp="$(list -prefix ,\" -suffix /include\" -loop-cmd 'pack_get -prefix' $(pack_get -mod-req-path))"

pack_cmd "sed -i '$ a\
library_dirs += [\"$(pack_get -LD $(get_parent))\"]\n\
runtime_library_dirs += [\"$(pack_get -LD $(get_parent))\"]\n\
library_dirs += [\"$(pack_get -LD libxc)\"]\n\
runtime_library_dirs += [\"$(pack_get -LD libxc)\"]\n\
include_dirs += [\"$(pack_get -prefix libxc)/include\"]\n\
libraries += [\"xc\"]\n\
include_dirs += [\"$(pack_get -prefix mpi)/include\"]\n\
extra_compile_args = \"$pCFLAGS -std=c99\".split(\" \")\n\
mpi_runtime_library_dirs += [\"$(pack_get -LD mpi)\"]\n\
mpi_runtime_library_dirs += [\"$(pack_get -LD hdf5)\"]\n\
scalapack = True\n\
define_macros += [(\"GPAW_NO_UNDERSCORE_CBLACS\", \"1\")]\n\
define_macros += [(\"GPAW_NO_UNDERSCORE_CSCALAPACK\", \"1\")]\n\
elpa = False\n\
library_dirs += [\"$(pack_get -LD elpa)\"]\n\
runtime_library_dirs += [\"$(pack_get -LD elpa)\"]\n\
libraries += [\"elpa\"]\n\
\n\
hdf5 = $hdf\n\
library_dirs += [\"$(pack_get -LD hdf5)\"]\n\
runtime_library_dirs += [\"$(pack_get -LD hdf5)\"]\n\
libraries += \"hdf5_hl hdf5\".split()\n\
library_dirs += [\"$(pack_get -LD zlib)\"]\n\
runtime_library_dirs += [\"$(pack_get -LD zlib)\"]\n\
libraries += [\"z\"]\n\
fftw = True\n\
library_dirs += [\"$(pack_get -LD fftw)\"]\n\
runtime_library_dirs += [\"$(pack_get -LD fftw)\"]\n\
libraries += [\"fftw3\"]\n\
extra_link_args += map(lambda s: \"-Wl,-rpath=\"+s,runtime_library_dirs)\n\
# distutils seems to break -R since it can not recognise GCC\n\
runtime_library_dirs = []\n\
# Add all directories for inclusion\n\
include_dirs += [${tmp:1}]' $file"
unset hdf

pack_cmd "unset LDFLAGS"

if [[ $(vrs_cmp $v 20) -lt 0 ]]; then
    pack_cmd "GPAW_CONFIG='$file' $_pip_cmd . --install-option='--customize=$file' --prefix=$(pack_get -prefix)"
else
    pack_cmd "GPAW_CONFIG='$file' $_pip_cmd . --prefix=$(pack_get -prefix)"
fi


add_test_package gpaw.exec.parallel

pack_set -host-reject $(get_hostname)
# We need the setups for the tests
pack_set -mod-req gpaw-setups
pack_set -mod-req ase
pack_cmd "unset LDFLAGS"
pack_cmd "$(get_parent_exec) \$(which gpaw-test) 2>&1 > gpaw.serial || echo forced"
pack_store gpaw.serial
pack_cmd "gpaw-python \$(which gpaw-test) 2>&1 > gpaw.exec.serial || echo forced"
pack_store gpaw.exec.serial
pack_cmd "mpirun -np 2 gpaw-python \$(which gpaw-test) 2>&1 > gpaw.exec.parallel || echo forced"
pack_store gpaw.exec.parallel

done
