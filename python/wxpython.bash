# apt-get libgtk-3-dev libgstreamer1.0-0 libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
add_package \
    --package wxpython \
    https://github.com/wxWidgets/Phoenix/releases/download/wxPython-4.1.0/wxPython-4.1.0.tar.gz

pack_set --host-reject $(get_hostname)
pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set $(list --prefix ' --module-requirement ' wxwidgets sip)

pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages"

pack_cmd "unset LDFLAGS"
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "$(get_parent_exec) setup.py install" \
	 "--prefix=$(pack_get --prefix)"
