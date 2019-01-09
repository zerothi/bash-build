_mname=$(uname -m)

v=3.25
add_package --directory pdtoolkit-$v \
	    https://www.cs.uoregon.edu/research/tau/pdt_releases/pdt-$v.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/$_mname/bin/pdtflint

pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/$_mname/bin"

# Install commands that it should run
pack_cmd "./configure" \
	 "-prefix=$(pack_get --prefix)"
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"


# Install tau
add_package https://www.cs.uoregon.edu/research/tau/tau_releases/tau-2.28.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --module-requirement pdt \
	 --module-requirement mpi \
	 --module-requirement unwind

tmp_flags=
if [[ $(pack_installed papi) -eq $_I_INSTALLED ]]; then
    pack_set --module-requirement papi
    tmp_flags="$tmp_flags -papi=$(pack_get --prefix papi)"
fi

pack_set --install-query $(pack_get --prefix)/$_mname/bin/tauex

pack_set --module-opt "--prepend-ENV PATH=$(pack_get --prefix)/$_mname/bin"

# Install commands that it should run
# bfd = binutils
pack_cmd "./configure -c++=$CXX -cc=$CC -fortran=$FC" \
	 "-unwind=$(pack_get --prefix unwind)" \
	 "-pdt=$(pack_get --prefix pdt)" \
	 "-bfd=$(pack_get --prefix build-tools)" \
	 "-openmp -mpi -mpit" \
	 "-useropt='$CFLAGS'" \
	 "-PROFILEMEMORY" \
	 "-prefix=$(pack_get --prefix) $tmp_flags"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

unset _mname
