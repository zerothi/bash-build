msg_install --message "Will install helper default modules now"

# fetch default versions
def_build=$(build_get --default-build)
def_version=$(build_get --def-module-version)

# Revert to the generic build without specifying compiler version
build_set --non-default-module-version
build_set --default-build generic-no-version

# Source the file for obtaining correct env-variables
tmp=$(build_get --default-build)
source $(build_get --source[$tmp])
unset tmp

if [ $(pack_get --installed gcc) -eq 1 ]; then
    create_module \
	--module-path $(build_get --module-path)-npa \
	-n "Nick Papior Andersen's script for loading gcc: $(pack_get --version gcc)." \
	-v $(pack_get --version gcc) \
	-M $(pack_get --alias gcc).$(pack_get --version gcc) \
	-P "/directory/should/not/exist" -RL gcc 
fi

for i in $(get_index --all git) ; do
    create_module \
	--module-path $(build_get --module-path)-npa \
	-n "Nick Papior Andersen's script for loading git: $(pack_get --version $i)." \
	-v $(pack_get --version $i) \
	-M $(pack_get --alias $i).$(pack_get --version $i) \
	-P "/directory/should/not/exist" -RL $i
done

if [ $(pack_get --installed doxygen) -eq 1 ]; then
    create_module \
	--module-path $(build_get --module-path)-npa \
	-n "Nick Papior Andersen's script for loading doxygen: $(pack_get --version doxygen)." \
	-v $(pack_get --version doxygen) \
	-M $(pack_get --alias doxygen).$(pack_get --version doxygen) \
	-P "/directory/should/not/exist" -RL doxygen 
fi

if [ $def_version -eq 1 ]; then
    build_set --default-module-version
fi
build_set --default-build $def_build
unset def_build def_version
