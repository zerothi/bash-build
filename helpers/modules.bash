# apt-get install tcl8.X-dev
#add_package --build generic-no-version http://downloads.sourceforge.net/project/modules/Modules/modules-3.2.10/modules-3.2.10.tar.gz
# 4.1.4 has errors in configure
v=4.2.1
v=4.1.2
add_package --build generic-no-version https://github.com/cea-hpc/modules/releases/download/v$v/modules-$v.tar.bz2

pack_set --install-query $(pack_get --prefix)/$v/bin/envml

# Fix csh tests
pack_cmd "sed -i -e 's:/bin/csh 2:/bin/csh -f 2:g' compat/configure"

# Install commands that it should run
pack_cmd "./configure" \
	 "--without-pager" \
	 "--prefix=$(pack_get --prefix) --enable-versioning"

# Make commands
pack_cmd "make all $(get_make_parallel)"
pack_cmd "make install"
