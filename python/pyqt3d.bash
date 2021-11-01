v=5.15.4
add_package --version $v --package pyqt3d \
	    https://sourceforge.net/projects/pyqt/files/PyQt3D/PyQt3D-$v/PyQt3D_gpl-$v.tar.gz

[[ "x${pV:0:1}" != "x3" ]] && pack_set --host-reject $(get_hostname)
pack_set --host-reject $(get_hostname)

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --prefix)/bin/pyqt3d

pack_set $(list --prefix ' --module-requirement ' pyqt)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

p=$(pack_get --prefix)
pack_cmd "$(get_parent_exec) configure.py" \
	 "--sip=$(pack_get --prefix sip)/bin/sip" \
	 "--sip-incdir=$(pack_get --prefix sip)/include" \
	 "--pyqt-sipdir=$(pack_get --prefix pyqt)/include" \
	 "-d $p/lib/python$pV/site-packages/"

pack_cmd "make"
pack_cmd "make install"
