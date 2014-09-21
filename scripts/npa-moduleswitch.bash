_npa_new_name

cat <<EOF > $script
#!/bin/bash

# This script enables the change between modules

# First a function to kill any ENV-vars that might be contained in
# the module env
#function _switch_modules_clean {

  # Unset env's from ENV-MODULES
  unset MODULE_VERSION
  unset MODULE_VERSION_STACK
  unset MODULESHOME
  unset LOADEDMODULES
  unset MODULEPATH

  # Unset env's from Lmod
  unset MODULEPATH_ROOT
  unset MODULEPATH
  unset BASH_ENV
  unset SET_TITLE_BAR
  unset SHOST
  unset PROMPT_COMMAND
  for e in \$(env | grep _ModuleTable | awk -F = '{print \$1}') ; do
     eval "unset \$e"
  done
  for e in \$(env | grep -e LMOD -e _LMOD -e __LMOD | awk -F = '{print \$1}') ; do
     eval "unset \$e"
  done
  for e in \$(env | grep TACC | awk -F = '{print \$1}') ; do
     eval "unset \$e"
  done

  # Unset functions from ENV-MODULES
  unset module

  # Unset functions from Lmod
  unset module
  unset ml
  unset clearMT
  unset xSetTitleLmod
#}
EOF

pack_set --command "mv $(pwd)/$script $(pack_get --prefix)/bin/_switch_modules_clean"

_npa_new_name

cat <<EOF > $script
#!/bin/bash

# Function to reinstall old modulepath
#function _switch_reuse_modulepath {

  if [ ! -z "\$_SWITCH_NPA_MODPATH" ]; then
     for p in \${_SWITCH_NPA_MODPATH//:/ } ; do
       [ -z "\${p// /}" ] && continue
       module unuse \$p
       module use --append \$p
     done
     unset _SWITCH_NPA_MODPATH
  fi
  
#}
EOF

pack_set --command "mv $(pwd)/$script $(pack_get --prefix)/bin/_switch_reuse_modulepath"


_npa_new_name

cat <<EOF > $script
#!/bin/bash

# Function to load Lmod
#function switch2lmod {

  module purge 2>/dev/null
  module --force purge 2>/dev/null

  export _SWITCH_NPA_MODPATH="\$MODULEPATH"

  source $(pack_get --prefix)/bin/_switch_modules_clean

  source $(pack_get --prefix lmod)/lmod/lmod/init/bash

  source $(pack_get --prefix)/bin/_switch_reuse_modulepath
  
#}
EOF

pack_set --command "mv $(pwd)/$script $(pack_get --prefix)/bin/switch2lmod"

_npa_new_name

cat <<EOF > $script
#!/bin/bash

# Function to load Modules
#function switch2em {

  module purge 2>/dev/null
  module --force purge 2>/dev/null

  export _SWITCH_NPA_MODPATH="\$MODULEPATH"

  source $(pack_get --prefix)/bin/_switch_modules_clean

  source $(pack_get --prefix modules)/Modules/default/init/bash

  source $(pack_get --prefix)/bin/_switch_reuse_modulepath
  
#}
EOF


pack_set --command "mv $(pwd)/$script $(pack_get --prefix)/bin/switch2em"
