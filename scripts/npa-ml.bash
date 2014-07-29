
# Create new file
_npa_new_name
cat <<EOF > $script
#!/bin/bash

# This creates a shorthand for "module"

function ml {
    local args="" opt=load
    if [ \$# -gt 0 ]; then
        case $1 in
            load|add|rm|unload|swap|switch|purge|refresh|update)
                opt=\$1 ; shift ;;
            show|display|help|clear)
                opt=\$1 ; shift ;;
            av|avail)
                opt=avail ; shift ;;
        esac
    else
        opt=list
    fi
    module $opt $@
}

EOF

pack_set --command "mv $(pwd)/$script $(pack_get --install-prefix)/source/ml.function"

_npa_new_name
cat <<EOF > $script
#!/bin/bash

# This creates the autocompletion for "ml"

source \$NPA_SOURCE/ml.function

function _ml {
    local cur="\$2"
    COMPREPLY=( \$(compgen -W "\$(_module_not_yet_loaded)" -- "\$cur"))
}
complete -F _ml ml

EOF

pack_set --command "mv $(pwd)/$script $(pack_get --install-prefix)/source/ml.bashrc"

_npa_new_name
cat <<EOF > $script
#!/bin/zsh

# This creates the autocompletion for "ml"

source \$NPA_SOURCE/ml.function

function _ml {
    local cur="\$2"
    COMPREPLY=( \$(compgen -W "\$(_module_not_yet_loaded)" -- "\$cur"))
}

complete -F _ml ml

EOF

pack_set --command "mv $(pwd)/$script $(pack_get --install-prefix)/source/ml.zshrc"


