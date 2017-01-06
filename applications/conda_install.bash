conda_V=$1

# Local package for the downloading and installation
# of conda packages (locally in the conda installation)
add_package --build generic conda${conda_V}_installs.local

pack_set --module-requirement conda
pack_set --directory .

pack_cmd "source activate python$conda_V"

_channel=
_conda=

# Specify the channel of the conda packages
function conda_channel {
    _channel="--channel $1"
    shift
}

# Append packages to the list of packages
function conda_append {
    while [[ $# -gt 0 ]]; do
	_conda="$_conda $1"
	shift
    done
}

# Do the installation of the packages
function conda_install {
    while [[ $# -gt 0 ]]; do
	conda_append $1
	shift
    done
    if [[ -n "$_conda" ]]; then
	# First try and download, always finish with a yes
	pack_cmd "conda install -y $_channel $_conda"
    fi
    # Empty again
    _channel=""
    _conda=""
}

# Add conda packages that is not part of a channel
conda_install nose

conda_append ssl_match_hostname
if [[ $(vrs_cmp $conda_V 2) -eq 0 ]]; then
    #conda_append bzr-fastimport
    conda_append enum34
    conda_append six
fi
conda_append certifi
conda_append cycler # for matplotlib
conda_append cffi
conda_append decorator
conda_append distribute
conda_append docutils
conda_append jinja2
conda_append jsonschema
conda_append line_profiler
conda_append markupsafe
conda_append mistune
conda_append mpmath # for sympy
conda_append mock
conda_append numpydoc
conda_append nose
conda_append pep8
conda_append pexpect
conda_append pkgconfig
conda_append ply
conda_append pyparsing
conda_append pycparser
conda_append pygments
conda_append python-dateutil
conda_append pyyaml
conda_append simplegeneric
conda_append sphinx sphinx_rtd_theme
conda_append traitlets
conda_append tornado
conda_append wheel

conda_append pyzmq
conda_append jupyter

conda_install

# Do numercial package installations
conda_append cython
conda_append numpy scipy matplotlib
conda_append sympy pandas
conda_append numexpr
conda_append h5py netcdf4
conda_append theano
conda_install


# Do my stuff
conda_channel zerothi
conda_append sisl sisl-dev
conda_install

unset conda_append
unset conda_install
unset conda_channel
unset _channel
unset _conda

unset conda_V
