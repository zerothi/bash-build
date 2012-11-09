# Install the distribute package locally
#add_package http://pypi.python.org/packages/source/d/distribute/distribute-0.6.30.tar.gz
add_package http://python-distribute.org/distribute_setup.py

pack_set --directory "./"
pack_set --command "$(get_parent_exec) distribute_setup.py"
pack_set --install-query "/always/install"

pack_install