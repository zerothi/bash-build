_npa_new_name
cat <<EOF > $script
#!/bin/bash

# This script will enable the creation of easy PBS scripts

# First retreive the hostname
_hostname="\$(hostname -s)"

# Set default options:
single_paffinity=0
walltime=01:00:00
nodes=1
ppn=1
has_np_cmd=0

if [ "xn-" == "x\${_hostname:0:2}" ] || \
   [ "xgray" == "x\${_hostname:0:4}" ] || \
   [ "xhpc-fe" == "x\${_hostname:0:6}" ]
then
    has_np_cmd=1
    queue="fotonano"
fi

message=""
mail=""
inout=""
show_flag=0
access_policy=SHARED

function _spbs_add_PBS_option {
    # Takes three arguments
    # \$1 is the flag for the PBS option
    # \$2 is the argument for the flag
    # \$3 is the message for the flag (printed above the flag)
    [ -z "\$2" ] && return 0
    if [ \$show_flag -eq 1 ]; then
        echo "## \$3"
    fi  
    echo "#PBS \$1 \$2"
}

function _spbs_add_line {
    # Takes three arguments
    # \$1 is the line
    # \$2 is the message for the line
    [ -z "\$1" ] && return 0
    if [ \$show_flag -eq 1 ]; then
        echo "# \$2"
    fi  
    echo "\$1"
}


function _spbs_help {
    local format="    %s :\n         %s\n"
    echo "Usage of \$(basename \$0): Aid in the creation of PBS scripts."
    echo ""
    printf "\$format" "--name|-N" "The name of the PBS job"
    printf "\$format" "--queue|-q" "Queue the job should be submitted to, only specifying queue will clear walltime."
    printf "\$format" "--walltime|-W" "The time of execution [hh:mm:ss]."
    printf "\$format" "--days|-dd" "The time of execution in days. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--hours|-hh" "The time of execution in hours. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--minutes|-mm" "The time of execution in minutes. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--nodes|-n" "Number of nodes requested"
    printf "\$format" "--processors-per-node|-ppn" "Number of cores per node requested"
    printf "\$format" "--message-begin" "Mail when the job begins"
    printf "\$format" "--message-error" "Mail when the job quits on error"
    printf "\$format" "--message-abort" "Mail when the PBS system aborts the job"
    printf "\$format" "--message-ae" "Short-hand for --message-abort --message-error."
    printf "\$format" "--message-e" "Short-hand for --message-error."
    printf "\$format" "--mail-address|-mail" "Redirect the mails to given mail address."
    printf "\$format" "--mix-in-out|-joe" "The stderr and stdout will be directed to stdout."
    printf "\$format" "--no-paffinity|--paffinity" "Do (not) create the paffinity ENV when on a single node."
#    printf "\$format" "--access-policy" "Set the access policy for the job, can be (SHARED|SINGLEUSER|SINGLEJOB|SINGLETASK)."
#    printf "\$format" "--alone" "Require to occupy a full node alone."
    printf "\$format" "--flag-explanations|-fe" "Add flag explanations in the PBS script."
}




while [ \$# -ne 0 ]; do
    opt="\$1" # Save the option passed
    case \$opt in
        --*) opt="\${opt:1}" ;;
    esac
    shift
    case \$opt in 
        -name|-N) name="\$1" ; shift ;;
        -queue|-q) queue="\$1" ; shift ;;
        -walltime|-W) walltime="\$1" ; shift ;;
        -days|-dd) walltime="\$((\$1*24)):\${walltime#*:}" ; shift ;;
        -hours|-hh) walltime="\$1:\${walltime#*:}" ; shift ;;
        -minutes|-mm) walltime="\${walltime%%:*}:\$1:\${walltime##*:}" ; shift ;;
        -nodes|-n) nodes="\$1" ; shift ;;
        -processors-per-node|-ppn) ppn="\$1" ; shift ;;
        -message-begin) message="b\$message" ;;
        -message-error) message="e\$message" ;;
        -message-abort) message="a\$message" ;;
        -message-ae) message="ae" ;;
        -message-e) message="e" ;;
        -mail-address|-mail|-M) mail="\$1" ; shift ;;
        -mix-in-out|-joe) inout=oe ;;
        -paffinity) single_paffinity=1 ;;
        -no-paffinity) single_paffinity=0 ;;
        -flag-explanations|-fe) show_flag=1 ;;
#        -access-policy) access_policy="\$1" ; shift ;; 
        -help|-h) _spbs_help ; exit 0 ;;
        *)
            echo "Could not recognize flag: \$opt"
            _spbs_help ; exit 1 ;;
    esac
done

# Correct for default options
[ -z "\$message" ] && message=ae

# Correct the access policy statement
case \$access_policy in
    shared|SHARED) access_policy=SHARED ;;
    singleuser|SINGLEUSER) ;;
    singletask|SINGLETASK) ;;
    singlejob|SINGLEJOB) ;;
    *)
         echo "Could not recognize flag for access-policy: \$access-policy"
         _spbs_help ; exit 1 ;;
esac


echo "#!/bin/sh"
_spbs_add_PBS_option -N "\$name" "The name of the PBS script"
_spbs_add_PBS_option -q "\$queue" "The queue that the script is submitted to"
_spbs_add_PBS_option -l "nodes=\$nodes:ppn=\$ppn" "Determines the processors, nodes = computers, ppn = cores used on each computer [nodes=2:ppn=4] => 8 cpu's"
_spbs_add_PBS_option -l "walltime=\$walltime" "The allowed execution time. Will quit if the execution time exceeds this limit."
_spbs_add_PBS_option -m "\$message" "Mail upon [a] = PBS abort, [e] = execution error, [b] = begin execution."
_spbs_add_PBS_option -M "\$mail" "Mail address to send job information (defaulted to the mail assigned the login user)."
_spbs_add_PBS_option -j "\$inout" "Combines the stdout and stderr output to the stdout (thus no error file will be created)."
if [ "x\$access_policy" != "xSHARED" ]; then
_spbs_add_PBS_option -l "NACCESSPOLICY=\$access_policy" "Determines the access policy of the jobs. SHARED: everybody can run simultaneously. \\
SINGLEUSER: only the same user can run. \\
SINGLETASK: only one task from the same job can run. \\
SINGLEJOB: only one job can run."
fi

echo ''
_spbs_add_line 'source \$PBS_O_HOME/.bashrc' "Source the home .bashrc to edit ENV variables"
_spbs_add_line 'module purge' "Clear list of defaulted modules"
_spbs_add_line 'module load npa-cluster-setup' "Enables the NPA modules"
echo ''
_spbs_add_line 'ulimit -s unlimited' "Ensure the stack-size unlimited"
_spbs_add_line 'date' "Show the date and time of execution"
_spbs_add_line 'cd \$PBS_O_WORKDIR' "Change directory to the actual execution folder"
if [ \$has_np_cmd -eq 1 ]; then
_spbs_add_line '# \$PBS_NP is the number of processors available' "The total number of cores is precomputed for you [\$((nodes*ppn))] and saved in the env-variable PBS_NP"
else
_spbs_add_line 'NPROCS=\$(wc -l < \$PBS_NODEFILE)' "Retrieve the number of cores used in total [should be \$((nodes*ppn))]"
fi
if [ \$nodes -eq 1 ] && [ \$single_paffinity -eq 1 ]; then
_spbs_add_line 'export OMPI_MCA_mpi_paffinity_alone=1' "Ensure that MPI utilizes the best connection mode when on a single node DO NOT USE IF NOT OCCUPYING FULL NODE"
fi
echo ''

EOF

pack_set --command "mv $(pwd)/$script $(pack_get --install-prefix)/bin/spbs"
