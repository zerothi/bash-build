add_package https://files.pythonhosted.org/packages/48/75/98987181e897ef378d6c239ee733328a7264a41f2d8263e61d7b7c4c0909/sip-6.7.9.tar.gz
pack_set -s $IS_MODULE

pack_set --install-query $(pack_get -prefix)/bin/sip-build

# This module requires flex and bison to be built, try by loading
# those that are installed...
for m in flex bison ; do
    if [[ $(pack_installed $m) -eq 1 ]]; then
    pack_set -build-mod-req $m
    fi
done

#pack_cmd "$(get_parent_exec) lib/configure.py -b $p/bin" \
#	 "-d $p/lib/python$pV/site-packages/ --stubsdir $p/lib/python$pV/site-packages/" \
#	 "-e $p/include -v $p/sip"

pack_cmd "$_pip_cmd . --prefix=$(pack_get -prefix)"

