# apt-get install tcl8.X-dev
#add_package --build generic-no-version http://downloads.sourceforge.net/project/modules/Modules/modules-3.2.10/modules-3.2.10.tar.gz
add_package --build generic https://github.com/cea-hpc/modules/releases/download/v4.0.0/modules-4.0.0.tar.bz2

pack_set --install-query $(pack_get --prefix)/bin/envml

if [[ $(vrs_cmp $(pack_get --version) 3.2) -le 0 ]]; then
    local f=$(pwd_archives)/modules-env-8.6.patch
    
    dwn_file http://www.student.dtu.dk/~nicpa/packages/environment-modules-tcl86.patch $f
    
    # Patch for compatibility with 8.6
    pack_cmd "patch -p1 < $f"
fi

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix=$(pack_get --prefix) --enable-versioning"

# Make commands
pack_cmd "make all $(get_make_parallel)"
pack_cmd "make install"
