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

_pip=
function pip_append {
    while [[ $# -gt 0 ]]; do
	_pip="$_pip $1"
	shift
    done
}

function pip_install {
    #pack_cmd "pip install $1"
    if [[ ! -z "$_pip" ]]; then
	pack_cmd "pip install -U $_pip"
	# Empty again
	_pip=""
    fi
    while [[ $# -gt 0 ]]; do
	pack_cmd "pip install -U $1"
	shift
    done
}

# First install its own usage
pip_install pip

# Packages in alphabetic order

pip_append autopep8
pip_append backports.ssl_match_hostname
if [[ ${pV:0:1} -eq 2 ]]; then
    pip_install bzr
    #pip_install bzr-fastimport
fi
pip_append certifi
pip_append cffi
pip_append decorator
pip_append distribute
pip_append docutils
pip_append enum34
pip_append fastimport
pip_append jinja2
pip_append jsonschema
pip_append jupyter
pip_append markupsafe
pip_append mistune
pip_append mock
#pip_append monty
pip_append nose
pip_append pandoc
pip_append pep8
pip_append pexpect
#pip_append pint
pip_append pkgconfig
pip_append pyparser
pip_append pycparser
pip_append pygments
pip_append python-dateutil
#pip_append pytz
pip_append pyyaml
pip_append pyzmq
pip_append simplegeneric
pip_append six
pip_append sphinx
pip_append traitlets
pip_append tornado

pip_install

unset pip_append
unset pip_install
