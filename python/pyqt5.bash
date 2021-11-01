v=5.15.6
add_package --version $v --package pyqt \
	    https://www.riverbankcomputing.com/static/Downloads/PyQt5/$v/PyQt5-$v.tar.gz

pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/pyuic5

pack_set $(list --prefix ' --module-requirement ' sip)

pack_cmd "mkdir -p $(pack_get --prefix)/lib/python$pV/site-packages"

p=$(pack_get --prefix)
pack_cmd "$(get_parent_exec) configure.py --confirm-license" \
	 "--sip=$(pack_get --prefix sip)/bin/sip" \
	 "--sip-incdir=$(pack_get --prefix sip)/include" \
	 "-b $p/bin -d $p/lib/python$pV/site-packages/" \
	 "--stubsdir $p/lib/python$pV/site-packages/"

pack_cmd "make"
pack_cmd "make install"
