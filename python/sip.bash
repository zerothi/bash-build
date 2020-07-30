v=4.19.23
add_package https://www.riverbankcomputing.com/static/Downloads/sip/$v/sip-$v.tar.gz
pack_set -s $IS_MODULE

pack_set --install-query $(pack_get --prefix)/bin/sip

# This module requires flex and bison to be built, try by loading
# those that are installed...
for m in flex bison ; do
    if [[ $(pack_installed $m) -eq 1 ]]; then
	pack_cmd "module load $(pack_get --module-name-requirement $m) $(pack_get --module-name $m)"
    fi
done

p=$(pack_get --prefix)
pack_cmd "$(get_parent_exec) configure.py -b $p/bin" \
	 "-d $p/lib/python$pV/site-packages/ --stubsdir $p/lib/python$pV/site-packages/" \
	 "-e $p/include -v $p/sip"

pack_cmd "make"
pack_cmd "make install"

# Unload again...
for m in flex bison ; do
    if [[ $(pack_installed $m) -eq 1 ]]; then
	pack_cmd "module unload $(pack_get --module-name $m) $(pack_get --module-name-requirement $m)"
    fi
done


