add_package https://pypi.python.org/packages/source/p/pysqlite/pysqlite-2.8.3.tar.gz

[ "x${pV:0:1}" == "x3" ] && pack_set --host-reject $(get_hostname)

pack_set --module-requirement sqlite
pack_set --install-query $(pack_get --prefix $(get_parent))/lib/python$pV/site-packages/$(pack_get --package)-$(pack_get --version)-py$pV.egg-info

# Create the sqlite setup.cfg
file=setup.cfg
pack_cmd "echo '# Setup for pysqlite' > $file"
pack_cmd "sed -i '$ a\
[build_ext]\n\
include_dirs = $(pack_get --prefix sqlite)/include\n\
library_dirs = $(pack_get --LD sqlite)\n\
#runtime_library_dirs = $(pack_get --LD sqlite)\n\
rpath = $(pack_get --LD sqlite)\n\
libraries = sqlite3\n\
define = SQLITE_OMIT_LOAD_EXTENSION\n' $file"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix $(get_parent))"
