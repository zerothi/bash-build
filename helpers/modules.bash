add_package --build generic-no-version http://downloads.sourceforge.net/project/modules/Modules/modules-3.2.10/modules-3.2.10.tar.gz

pack_set -s $MAKE_PARALLEL

pack_set --install-query $(pack_get --prefix)/Modules

local f=$(pwd_archives)/modules-env-8.6.patch

dwn_file http://www.student.dtu.dk/~nicpa/packages/environment-modules-tcl86.patch $f

# Patch for compatibility with 8.6
pack_cmd "patch -p1 < $f"

# Install commands that it should run
pack_cmd "./configure" \
	 "--prefix $(pack_get --prefix)"

# Make commands
pack_cmd "make $(get_make_parallel)"
pack_cmd "make install"

# Make link to default version (always the newest version, latest installation)
pack_cmd "cd $(pack_get --prefix)/Modules/"
pack_cmd "ln -fs $(pack_get --version) default" 
