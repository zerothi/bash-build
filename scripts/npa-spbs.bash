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
   [ "xhpc-fe" == "x\${_hostname:0:6}" ] || \
   [ "xhpclogin" == "x\${_hostname:0:8}" ]
then
    has_np_cmd=1
    queue="fotonano"
fi

message=""
mail=""
inout=""
show_flag=0
access_policy=SHARED
omp=1
mpi=0

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
    printf "\$format" "--nodes|-n|-p" "Number of nodes requested"
    printf "\$format" "--processors-per-node|-ppn" "Number of cores per node requested"
    printf "\$format" "--mail-begin|-m-b" "Mail when the job begins"
    printf "\$format" "--mail-error|-m-e" "Mail when the job quits on error"
    printf "\$format" "--mail-abort|-m-a" "Mail when the PBS system aborts the job"
    printf "\$format" "--mail-ae|-m-ae" "Shorthand for abort/error mail"
    printf "\$format" "--mail-n|--no-mail|-m-n" "Do not send any mails"
    printf "\$format" "--mail-(letters)|-m-(letters)" "Short-hand for combining -m-b -m-e or all of them."
    printf "\$format" "--[no-]mpi" "Is the job parallel with MPI."
    printf "\$format" "--[no-]omp" "Is the job threaded (can be supplied together with MPI-flag) [default=omp]."
    printf "\$format" "--mail-address|-mail" "Redirect the mails to given mail address."
    printf "\$format" "--mix-in-out|-joe" "The stderr and stdout will be directed to stdout."
    printf "\$format" "--no-paffinity|--paffinity" "Do (not) create the paffinity ENV when on a single node."
#    printf "\$format" "--access-policy" "Set the access policy for the job, can be (SHARED|SINGLEUSER|SINGLEJOB|SINGLETASK)."
#    printf "\$format" "--alone" "Require to occupy a full node alone."
    printf "\$format" "--flag-explanations|-fe" "Add flag explanations in the PBS script."
}


# Function for printing help which does not get piped
function _help {
    echo "MSG: \$@" >&2
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
        -nodes|-n|-p) nodes="\$1" ; shift ;;
        -processors-per-node|-ppn) ppn="\$1" ; shift ;;
        -mail-begin|-m-b) message="b\$message" ;;
        -mail-error|-m-e) message="e\$message" ;;
        -mail-abort|-m-a) message="a\$message" ;;
        -mail-ae|-m-ae) message="ae" ;;
        -mail-n|-no-mail|-m-n) message="n" ;;
        -mail-address|-mail|-M) mail="\$1" ; shift ;;
        -mix-in-out|-joe) inout=oe ;;
        -no-mpi) mpi=0 ;;
        -mpi) mpi=1 ; [ \$omp -eq 1 ] && omp=0 ;;
        -no-omp) omp=0 ;;
        -omp) omp=2 ;;
        -paffinity) single_paffinity=1 ;;
        -no-paffinity) single_paffinity=0 ;;
        -flag-explanations|-fe) show_flag=1 ;;
#        -access-policy) access_policy="\$1" ; shift ;; 
        -help|-h) _spbs_help >&2 ; exit 0 ;;
        *)
            echo "Could not recognize flag: \$opt" >&2
            _spbs_help >&2; exit 1 ;;
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

_help "Please use \$(basename \$0) --help to see all available options."

if [ \$nodes -ge 2 ] && [ \$omp -lt 2 ]; then
  _help "Disabling OpenMP as you have requested +1 node."
  omp=0
fi

echo "#!/bin/sh"
_spbs_add_PBS_option -N "\$name" "The name of the PBS script"
_spbs_add_PBS_option -q "\$queue" "The queue that the script is submitted to"
_spbs_add_PBS_option -l "nodes=\$nodes:ppn=\$ppn" "Determines the processors, nodes = computers, ppn = cores used on each computer [nodes=2:ppn=4] => 8 cpu's"
if [ \$has_np_cmd -eq 1 ]; then
  if [ \$((\$nodes*\$ppn)) -le 8 ]; then
    _help "With <= 8 cores you will automatically only be assigned to the AMD machines"
    _spbs_add_PBS_option -l "feature='Opteron2220|Opteron2354|Opteron2382|Opteron6136'" "Only requests processors of AMD type"
  fi
fi
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
_spbs_add_line 'env' "For debugging purposes"
echo ''
_spbs_add_line 'ulimit -s unlimited' "Ensure an unlimited stack-size"
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

# Add typical setup for MPI/OpenMP
if [ \$mpi -eq 1 ]; then
  _help "You are using MPI. Please edit the submit-script and ensure a working MPI executable"
  _spbs_add_line 'exit 0 # load MPI' "Ensure that you have loaded the correct MPI command, then delete this"
  if [ \$omp -gt 0 ]; then
    _help "You are creating a hybrid MPI/OpenMP script."
    _spbs_add_line "mpirun --map-by ppr:1:socket:pe=\$ppn -x OMP_NUM_THREADS=\$ppn -x OMP_PROC_BIND=true <executable>" "Setup the MPI call to figure out the number of cores used, for 2 sockets machines you need \$((\$ppn/2))"
  else
    _help "You are creating an MPI script."
    _spbs_add_line 'mpirun <executable>' "Setup the MPI call, do NOT specify -np as Torque is built in"
  fi
elif [ \$omp -gt 0 ]; then
  _help "You are creating an OpenMP script (no MPI)."
  if [ \$has_np_cmd -eq 1 ]; then
    _spbs_add_line 'export OMP_NUM_THREADS=\$PBS_NP' "Ensures the correct number of processes used by threading (requires BASH)"
  else
    _spbs_add_line 'export OMP_NUM_THREADS=\$NPROCS' "Ensures the correct number of processes used by threading (requires BASH)"
  fi
fi

EOF

pack_set --command "mv $(pwd)/$script $(pack_get --prefix)/bin/spbs"
