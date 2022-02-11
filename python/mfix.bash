v=20.2.0
add_package https://mfix.netl.doe.gov/s3/abb8f49f/f1599988c43836514926e200d9da5020//source/mfix/mfix-$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE -s $BUILD_DIR

if [[ $(vrs_cmp $pV 3.5) -lt 0 ]]; then
    pack_set -host-reject $(get_hostname)
fi

pack_set -module-opt "--set-ENV MFIX_HOME=$(pack_get -prefix)"
pack_set -module-opt "--set-ENV MFIX_TEMPLATES=$(pack_get -prefix)/templates"
pack_set -module-opt "-ld-library-path"

pack_set -install-query $(pack_get -prefix)/bin/mfixsolver

pack_set -build-mod-req cmake
pack_set $(list -prefix ' -module-requirement ' mpi numpy)

pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages"

# First build the source code and install
# Install commands that it should run
# -DENABLE_POSTMFIX=1
pack_cmd "CC='$MPICC' FC='$MPIFC' cmake -DCMAKE_BUILD_TYPE=Release" \
	 -DENABLE_MPI=1 \
     -DVERSION=$v \
     -DENABLE_OpenMP=1 \
	 "-DCMAKE_Fortran_COMPILER='$MPIFC'" \
	 "-DMPI_Fortran_COMPILER='$MPIFC'" \
	 "-DCMAKE_Fortran_FLAGS='$FFLAGS'" \
	 "-DCMAKE_INSTALL_PREFIX=$(pack_get -prefix)/bin .."
# Make commands
pack_cmd "make $(get_make_parallel)"
#pack_cmd "make $(get_make_parallel) postmfix"
pack_cmd "make install"

pack_cmd "cd ../"

# Fix paths for checking ENV-vars
pack_cmd 'sed -i -e "s/def conda_prefix/\ \ \ \ yield environ.get(\"MFIX_HOME\", None)\ndef conda_prefix/" mfixgui/tools/paths.py'
pack_cmd 'sed -i -e "s/dirname(sys.executable)/join(os.environ.get(\"MFIX_HOME\", \".\"), \"bin\")/" mfixgui/solver/manager.py'

pack_cmd "unset LDFLAGS && $_pip_cmd . --prefix=$(pack_get -prefix)"

pack_cmd "mkdir -p $(pack_get -prefix)/templates"
pack_cmd "mv tests queue_templates tutorials $(pack_get -prefix)/templates/"
pack_cmd "mkdir -p $(pack_get -prefix)/src"
pack_cmd "cp -rf CMakeLists.txt cmake model post_mfix tools $(pack_get -prefix)/src/"
