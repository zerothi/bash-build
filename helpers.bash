msg_install --message "Installing all helper modules if needed..."

source helpers/m4.bash
source helpers/autoconf.bash

# Install bison
source helpers/bison.bash
source helpers/flex.bash
source helpers/pcre.bash
source helpers/swig.bash