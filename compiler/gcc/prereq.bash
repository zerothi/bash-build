add_package --build generic --version $gcc_v \
	    --package gcc-prereq fake

# Define the correct installation-path
pack_set --prefix $(build_get --installation-path[generic])/gcc/$gcc_v
pack_set --install-query $(pack_get --prefix)/bin
pack_set --command "mkdir -p $(pack_get --prefix)/bin/"
pack_set --library-suffix "lib lib64"

# Denote that this package does not have a module
pack_set --installed $_I_LIB
