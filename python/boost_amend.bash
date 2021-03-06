add_package \
    -version $(pack_get -version boost) \
    -package boost-py$pV \
    $(pack_get -url boost)

pack_set -prefix $(pack_get -prefix boost)
pack_set -install-query $(pack_get -LD)/libboost_python${pV//./}.a

pack_cmd "./bootstrap.sh" \
	 "--with-libraries=python" \
	 "--with-python=$(get_parent_exec)" \
	 "--with-python-root=$(pack_get -prefix $(get_parent))" \
	 "--prefix=$(pack_get -prefix)" \
	 "--includedir=$(pack_get -prefix)/include" \
	 "--libdir=$(pack_get -LD)"

# Install commands that it should run
_p=$(pack_get -prefix $(get_parent))
[ -e $_p/include/python${pV}m ] && v=${pV}m || v=${pV}
pack_cmd "sed -i -e 's?using python.*?using python : $pV : $(get_parent_exec) : $_p/include/python$v : $_p/lib ;?' project-config.jam"

# Make commands
pack_cmd "./b2 --build-dir=build-tmp stage"
pack_cmd "./b2 --build-dir=build-tmp install --prefix=$(pack_get -prefix)"

