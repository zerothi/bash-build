add_package bash-PBS.local

pack_set -s $IS_MODULE

#pack_set --host-reject zeroth \
#    --host-reject ntch-2857

pack_set --directory .
pack_set --prefix-and-module $(pack_get --package)

pack_set --install-query $(pack_get --install-prefix)/bin/spbs

script=spbs.sh

cat <<EOF > $script
#!/bin/bash

# This script will enable the creation of easy PBS scripts

# First retreive the hostname
_hostname="\$(hostname -s)"

# Set default options:
walltime=01:00:00
nodes=1
if [ "x\$_hostname" == "xthul" ]; then
    ppn=8
elif [ "x\$_hostname" == "xsurt" ]; then
    ppn=16
else
    ppn=4
fi
message=""
mail=""
inout=""
show_flag=0

while [ \$# -ne 0 ]; do
    opt="\$1" # Save the option passed
    case \$opt in
        --*) opt="\${opt:1}" ;;
    esac
    shift
    case \$opt in 
        -name|-N) name="\$1" ; shift ;;
        -walltime|-W) time="\$1" ; shift ;;
        -nodes|-n) nodes="\$1" ; shift ;;
        -processors-per-node|-ppn) ppn="\$1" ; shift ;;
        -message-begins) message="b\$message" ;;
        -message-error) message="e\$message" ;;
        -message-abort) message="a\$message" ;;
        -message-ae) message="ae" ;;
        -message-e) message="e" ;;
        -mail-address|-mail|-M) mail="\$1" ; shift ;;
        -mix-in-out|-joe) inout=oe ;;
        -flag-explanations) show_flag=1 ;;
    esac
done

# Correct for default options
[ -z "\$message" ] && message=ae

function add_PBS_option {
    # Takes three arguments
    # \$1 is the flag for the PBS option
    # \$2 is the argument for the flag
    # \$3 is the message for the flag (printed above the flag)
    [ -z "\$2" ] && return 0
    if [ \$show_flag -eq 1 ]; then
        echo \$3
    fi  
    echo "#PBS \$1 \$2
}

echo "#!/bin/sh"
add_PBS_option -N "\$name" "The name of the PBS script"
add_PBS_option -l "nodes=\$nodes:ppn=\$ppn" "Determines the processors, node = computers, ppn = cores used on each computer [nodes=2:ppn=4] => 8 cpu\'s"
add_PBS_option -l "walltime=\$walltime" "The allowed execution time. Will quit if the execution time exceeds this limit."
add_PBS_option -m "\$message" "Mail upon [a] = PBS abort, [e] = execution error, [b] = begin execution."
add_PBS_option -M "\$mail" "Mail address to send job information (defaulted to the mail assigned the login user)."
add_PBS_option -j "\$inout" "Combines the stdout and stderr output to the stdout (thus no error file will be created)."

echo "source $HOME/.bashrc $hostname"
echo "module purge"
echo ""
echo "date"
echo "cd \$PBS_O_WORKDIR"
echo "NPROCS=\$(wc -l \$PBS_NODEFILE)"
echo ""
EOF

pack_set --command "mkdir -p $(pack_get --install-prefix)/bin"
pack_set --command "cp $(pwd)/$script $(pack_get --install-prefix)/bin/spbs"
pack_set --command "chmod a+x $(pack_get --install-prefix)/bin/spbs"

pack_install
rm $(pwd)/$script