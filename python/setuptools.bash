if [[ "x${pV:0:1}" == "x3" ]]; then
    v=58.4.0
else
    v=40.5.0
fi
	
add_package -archive setuptools-$v.tar.gz \
	    https://github.com/pypa/setuptools/archive/v$v.tar.gz

pack_set -install-query $(pack_get -prefix $(get_parent))/lib/python$pV/site-packages/setuptools.pth

pack_cmd "$(get_parent_exec) -s -m pip -vv install --no-build-isolation --no-deps . --prefix=$(pack_get -prefix $(get_parent))"


