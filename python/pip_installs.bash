#
# Instead of manually installing many packages that
# are installed within the local python installation.
#
# That makes life easier and is much easier to maintain
#

# Ensure that pip is installed before we proceed...
source_pack python/setuptools.bash
source_pack python/pip.bash


add_package pip_installs.local

pack_set --directory .

function pip_install {
    #pack_cmd "pip install $1"
    while [[ $# -gt 0 ]]; do
	pack_cmd "pip install -U $1"
	shift
    done
}

# First install its own usage
pip_install pip

# Packages in alphabetic order

pip_install autopep8
pip_install backports.ssl_match_hostname
pip_install bzr
#pip_install bzr-fastimport
pip_install certifi
pip_install cffi
pip_install decorator
pip_install distribute
pip_install docutils
pip_install enum34
pip_install fastimport
pip_install jinja2
pip_install jsonschema
pip_install jupyter
pip_install markupsafe
pip_install mistune
pip_install mock
#pip_install monty
pip_install nose
pip_install pandoc
pip_install pep8
pip_install pexpect
#pip_install pint
pip_install pkgconfig
pip_install pyparser
pip_install pycparser
pip_install pygments
pip_install python-dateutil
#pip_install pytz
pip_install pyyaml
pip_install pyzmq
pip_install simplegeneric
pip_install six
pip_install sphinx
pip_install traitlets
pip_install tornado
