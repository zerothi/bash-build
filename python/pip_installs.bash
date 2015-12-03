#
# Instead of manually installing many packages that
# are installed within the local python installation.
#
# That makes life easier and is much easier to maintain
#
# The downside is that the system requires internet
# access.
# However, one can circumvent that by doing a local
# installation which will let the user tar the directory
# and extract it on the remote node.
#

# Ensure that pip is installed before we proceed...
source_pack python/setuptools.bash
source_pack python/pip.bash

# Local package for the downloading and installation
# of pip packages (locally in the python installation)
add_package pip_installs.local

pack_set --directory .

# Create folder for pip-downloads
# Note this is version dependent
_pip_dwn=$(pwd_archives)/pip${pV:0:1}
mkdir -p $_pip_dwn

_pip=
function pip_append {
    while [[ $# -gt 0 ]]; do
	_pip="$_pip $1"
	shift
    done
}

function pip_install {
    if [[ -n "$_pip" ]]; then
	# First try and download, always finish with a yes
	pack_cmd "pip install --download $_pip_dwn/ $_pip ; echo 'yes'"
	pack_cmd "pip install --no-index --find-links $_pip_dwn $_pip"
	# Empty again
	_pip=""
    fi
    while [[ $# -gt 0 ]]; do
	pack_cmd "pip install --download $_pip_dwn/ $1 ; echo 'yes'"
	pack_cmd "pip install --no-index --find-links $_pip_dwn $1"
	shift
    done
}

# First install its own usage
pip_install pip

# Packages in alphabetic order

pip_append autopep8
pip_append backports.ssl_match_hostname
if [[ $(vrs_cmp $pV 2) -eq 0 ]]; then
    pip_append bzr
    #pip_append bzr-fastimport
    pip_append enum34
    pip_append six
    pip_append pandoc
fi
pip_append certifi
pip_append cffi
pip_append decorator
pip_append distribute
pip_append docutils
pip_append fastimport
pip_append jinja2
pip_append jsonschema
pip_append jupyter
pip_append markupsafe
pip_append mistune
pip_append mock
#pip_append monty
pip_append numpydoc
pip_append nose
pip_append pep8
pip_append pexpect
#pip_append pint
pip_append pkgconfig
pip_append pyparser
pip_append pyparsing
pip_append pycparser
pip_append pygments
pip_append python-dateutil
#pip_append pytz
pip_append pyyaml
pip_append pyzmq
pip_append simplegeneric
pip_append sphinx
pip_append traitlets
pip_append tornado

pip_install

unset pip_append
unset pip_install
