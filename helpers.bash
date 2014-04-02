msg_install --message "Installing all helper modules if needed..."

# Install modules
source helpers/modules.bash

source helpers/gnumake.bash

source helpers/help2man.bash
source helpers/m4.bash
source helpers/autoconf.bash
source helpers/automake.bash
source helpers/libtool.bash
source helpers/cmake.bash

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash

# Install LLVM generically
source helpers/zlib.bash
source helpers/libffi.bash
source helpers/llvm.bash

source helpers/numactl.bash

# Install git for those who want the newest release
source helpers/git.bash