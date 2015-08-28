msg_install --message "Will install helper default modules now"

# fetch default versions
def_build=$(build_get --default-build)
def_version=$(build_get --def-module-version)
mp=$(build_get --module-path)
mp=${mp//-generic/}

# Revert to the generic build without specifying compiler version
build_set --non-default-module-version
build_set --default-build generic-no-version

# Source the file for obtaining correct env-variables
tmp=$(build_get --default-build)
source $(build_get --source[$tmp])
unset tmp

for p in $(get_index --all gcc) \
	     $(get_index --all llvm) \
	     $(get_index --all git) \
	     doxygen graphviz 
do
    if [ $(pack_get --installed $p) -eq 1 ]; then
	create_module \
	    --module-path $mp-npa \
	    -n "Nick Papior Andersen's script for loading $(pack_get --alias $i): $(pack_get --version $p)." \
	    -v $(pack_get --version $p) \
	    -M $(pack_get --alias $p).$(pack_get --version $p) \
	    -P "/directory/should/not/exist" -RL $p 
    fi
done

if [ $def_version -eq 1 ]; then
    build_set --default-module-version
fi
build_set --default-build $def_build
unset def_build def_version mp
