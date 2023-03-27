msg_install -message "Installing all helper modules if needed..."


# Add a module which contains the default build tools
add_package -build generic -version 1.0 \
    -package build-tools fake
pack_set -s $IS_MODULE
pack_set -module-name build-tools/1.0
pack_set -prefix $(build_get -installation-path[generic])/build-tools/1.0
pack_set -install-query $(pack_get -prefix)/bin
pack_set -command "mkdir -p $(pack_get -prefix)/bin/"
pack_set -module-opt "-set-ENV PKG_CONFIG=$(pack_get -prefix)/bin/pkg-config"
tmp=$(which pkg-config)
if [[ $? -eq 0 ]]; then
    tmp=$(pkg-config --variable pc_path pkg-config)
    if [[ -n "$tmp" ]]; then
	pack_set -module-opt "-prepend-ENV PKG_CONFIG_PATH=$tmp"
    fi
fi

source_pack helpers/zlib.bash
#source_pack helpers/sysstat.bash

# These packages are installed in build-tools
source_pack helpers/help2man.bash
source_pack helpers/m4.bash
source_pack helpers/autoconf.bash
source_pack helpers/automake.bash
source_pack helpers/libtool.bash
#source_pack helpers/pkgconfig.bash
source_pack helpers/pkgconf.bash
# gnumake relies on libtool
source_pack helpers/gnumake.bash
source_pack helpers/texinfo.bash
# After all build-tools have been installed
source_pack helpers/binutils.bash
source_pack helpers/dejagnu.bash
source_pack helpers/ninja.bash

source_pack helpers/stow.bash
source_pack helpers/screen.bash
source_pack helpers/global.bash

# xdev (utilities)
source_pack helpers/imake.bash
source_pack helpers/makedepend.bash

# Tools for performance analysis
source_pack helpers/unwind.bash
source_pack helpers/wxwidgets.bash

source_pack helpers/libpng.bash
source_pack helpers/libgd.bash

source_pack helpers/cmake-bt.bash
source_pack helpers/cmake.bash
source_pack helpers/freetype.bash
source_pack helpers/libunistring.bash
source_pack helpers/libffi.bash

source_pack helpers/ccache.bash
# Install parallel binary
source_pack helpers/parallel.bash

# GPP
source_pack helpers/gpp.bash

# Build helpers
source_pack helpers/guile.bash
source_pack helpers/indent.bash
source_pack helpers/shtool.bash
source_pack helpers/bison.bash
source_pack helpers/flex.bash
source_pack helpers/pcre.bash
source_pack helpers/pcre2.bash

source_pack helpers/optipng.bash
source_pack helpers/openjpeg.bash

source_pack helpers/libxml2.bash

source_pack helpers/readline.bash
source_pack helpers/termcap.bash
source_pack helpers/openssl.bash
source_pack helpers/datamash.bash

source_pack helpers/libssh2.bash
source_pack helpers/libgit2.bash

source_pack helpers/curl.bash
source_pack helpers/nodejs.bash

# This will recreate the module with AC_LOCAL etc.
pack_set -installed $_I_TO_BE build-tools # Make sure it is "installed"
pack_install build-tools

source_pack helpers/numactl.bash

# Install git for those who want the newest release
source_pack helpers/git.bash

# Other helpers
source_pack helpers/doxygen.bash
source_pack helpers/ffmpeg.bash
source_pack helpers/gts.bash
source_pack helpers/graphviz.bash
source_pack helpers/sqlite.bash

source_pack helpers/boost.bash

source_pack helpers/swig.bash

source_pack helpers/bazel.bash

source_pack helpers/neovim.bash

# Install all compilers
source compiler/compilers.bash


source helpers/default.bash
