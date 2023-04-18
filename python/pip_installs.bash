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

# Local package for the downloading and installation
# of pip packages (locally in the python installation)
add_package pip_installs.local

pack_set --directory .

# Create folder for pip-downloads
# Note this is version dependent
_pip_dwn=$(pwd_archives)/pip$pV
mkdir -p $_pip_dwn

# -s disable userbase
_pip_cmd="$(get_parent_exec) -s -m pip"

_pip=
function pip_append {
    while [[ $# -gt 0 ]]; do
	_pip="$_pip $1"
	shift
    done
}

_pip_flags=
function pip_install {
    if [[ -n "$_pip" ]]; then
	# First try and download, always finish with a yes
	pack_cmd "$_pip_cmd download -d $_pip_dwn/ $_pip || echo forced"
	pack_cmd "$_pip_cmd install --no-index --find-links $_pip_dwn $_pip_flags $_pip"
	# Empty again
	_pip=""
    fi
    while [[ $# -gt 0 ]]; do
	pack_cmd "$_pip_cmd download -d $_pip_dwn/ $1 || echo forced"
	pack_cmd "$_pip_cmd install --no-index --find-links $_pip_dwn $_pip_flags $1"
	shift
    done
}

# Ensure we don't check together with locally installed stuff
# is probably double with python -s
pack_cmd "unset PYTHONUSERBASE"

pip_install pip wheel setuptools

pack_cmd "$_pip_cmd install -U pip wheel"

# Nose needs to be installed first
pip_install nose

_pip_flags="--no-deps"
pip_install lazy-object-proxy
_pip_flags=

pip_append autopep8
pip_append asteval
pip_append anaconda-client
pip_append attrs
pip_append backports.ssl_match_hostname
pip_append black
if [[ $(vrs_cmp $pV 2) -eq 0 ]]; then
    # the distribute package is horrendeous!!!
    # Therefore we need to install it without downloading it first.
    # Since 2020 Jan 1 we can't do this anymore... :(
    pack_cmd "$_pip_cmd install -U setuptools==44.1.0"
    #pack_cmd "$_pip_cmd install -U distribute"
    pip_append enum34
    pip_append six
    pip_append line_profiler
    pip_append pandoc
    pip_append lxml
    pip_append Pillow
fi
pip_append beniget
pip_append build
pip_append certifi
pip_append cffi
pip_append Click
pip_append cloudpickle
pip_append codecov
pip_append cycler # for matplotlib
pip_append decorator
pip_append docutils
pip_append fastimport
pip_append fastprogress
pip_append flake8 flake8-bugbear
pip_append flask $(list -prefix 'flask-' restx socketio cors login session)
pip_append FORD
pip_append fypp
pip_append gast
pip_append ipyvolume
[[ $(vrs_cmp $pV 2) -gt 0 ]] && pip_append gitpython
pip_append hypothesis
pip_append jinja2
pip_append joblib
pip_append jsonschema
# Until > 2.1.1 is out, we can't use it due to missing Cython updates
#pip_append line_profiler
pip_append markupsafe
pip_append Markdown
pip_append memory_profiler
pip_append mistune
pip_append mock
pip_append mpmath # for sympy
pip_append monty
pip_append nbsphinx
pip_append nose nose2
pip_append numpydoc
pip_append pathos
pip_append patsy
pip_append pep8 pep517
pip_append pexpect
pip_append pillow
pip_append pipenv
pip_append pint
pip_append pkgconfig
pip_append ply
pip_append poetry
pip_append psutil
#if [[ $(vrs_cmp $pV 3) -ge 0 ]]; then
    # Currently it cannot be installed due to non-ascii characters
    # in the changelog
    #pip_append pybinding
#fi
pip_append pyparser
pip_append pyparsing
pip_append pycparser
pip_append pyflakes
[[ $(vrs_cmp $pV 2) -gt 0 ]] && pip_append pygithub
pip_append pylint
pip_append pympler
pip_append pytest pytest-cov
pip_append pygments
pip_append python-dateutil
pip_append pytz
pip_append pyupgrade
pip_append pyyaml
pip_append requests
pip_append retrying
# Always install the latest and greatest setuptools_scm
pack_cmd "$_pip_cmd install -U setuptools_scm"
pip_append simplegeneric
pip_append simplejson
pip_append six
pip_append sphinx sphinx_rtd_theme sphinx-autoapi
if [[ $(vrs_cmp $pV 2) -eq 0 ]]; then
    pip_append subprocess32
fi
pip_append pathspec
pip_append scikit-build
pip_append pyproject-metadata
pip_append scikit-build-core
pip_append toml
pip_append toolz
pip_append tornado
pip_append tox
pip_append tqdm
pip_append traitlets
pip_append tuna
pip_append twine
pip_append uncertainties
pip_append versioneer
pip_append virtualenv
pip_append wheel

if ! $(is_host atto) ; then
    # Only install jupyter on this machine
    pip_append pyzmq
    pip_append jupyter nbconvert jupyterlab
    if [[ $(vrs_cmp $pV 3) -ge 0 ]]; then
       pip_append jupyterhub
    fi
    pip_append spyder
fi

pip_install

# Finally we need to remove the packages that are to be installed separately.
# This is because otherwise the "wrong" library will be used
pack_cmd "$_pip_cmd uninstall -y numpy pandas ; echo 'yes'"

_pip_cmd="$(get_parent_exec) -s -m pip -vv install --no-build-isolation"
unset _pip _pip_flags
unset pip_append
unset pip_install
