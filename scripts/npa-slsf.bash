script=$(tmp_file)
cat <<EOF > $script
#!/bin/bash

# This script will enable the creation of easy LSF scripts
# This script has been created by:
#  Nick R. Papior, 2015 -- 2019.
# Copyright.

# First retreive information on host
#_hostname="\$(hostname -s)"
#_groups="\$(groups \$USER)"

# Set default options (15 minutes)
walltime=00:00
procs=0
nodes=0
ppn=0

# Default to have LSF_NP env-var
queue=
    
message=""
mail=""
mem=
show_flag=0
# Default to not use OpenMP
# By far the greatest majority do not even know its existence.
omp=0
mpi=0

function _s_add_option {
    # Takes three arguments
    # \$1 is the flag for LSF option
    # \$2 is the argument for the flag
    # \$3 is the message for the flag (printed above the flag)
    [ -z "\$2" ] && return 0
    if [ \$show_flag -eq 1 ]; then
        if [ -n "\$3" ]; then
            echo "## \$3"
        fi
    fi  
    echo "#BSUB \$1 \$2"
}

function _s_add_message {
    # Takes one arguments
    # \$1 is the message
    [ -z "\$1" ] && return 0
    echo "# \$1"
}

function _s_add_line {
    # Takes two arguments
    # \$1 is the line
    # \$2 is the message for the line
    [ -z "\$1" ] && return 0
    if [ \$show_flag -eq 1 ]; then
        echo "# \$2"
    fi  
    echo "\$1"
}


function _s_help {
    local format="    %s :\n         %s\n"
    echo "Usage of \$(basename \$0): Aid in the creation of LSF submit scripts."
    echo ""
    printf "\$format" "--name|-N|-J" "The name of the LSF job"
    printf "\$format" "--queue|-q" "Queue the job should be submitted to, only specifying queue will clear walltime."
    printf "\$format" "--mem|-M" "Maximum memory used per process: xxxMB, xxxGB, default to MB"
    printf "\$format" "--walltime|-W" "The time of execution [hh:mm]."
    printf "\$format" "--days|-dd" "The time of execution in days. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--hours|-hh" "The time of execution in hours. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--minutes|-mm" "The time of execution in minutes. (-W,-dd,-hh,-mm can be combined)"
    printf "\$format" "--procs|-n" "Total number of processors requested"
    printf "\$format" "--nodes" "Number of nodes requested (--nodes * -ppn == --procs)"
    printf "\$format" "--processors-per-node|-ppn" "Number of cores per node requested"
    printf "\$format" "--mail-begin|-m-B" "Mail when the job begins"
    printf "\$format" "--mail-end|-m-N" "Mail when the job ends (regardless of success)"
    printf "\$format" "--mail-(letters)|-m-(letters)" "Short-hand for combining -m-B -m-N or all of them."
    printf "\$format" "--[no-]mpi" "Is the job parallel with MPI."
    printf "\$format" "--[no-]omp" "Is the job threaded (can be supplied together with MPI-flag) [default=omp]."
    printf "\$format" "--mail-address|-mail|-u" "Redirect the mails to given mail address."
    printf "\$format" "--flag-explanations|-fe" "Add flag explanations in the LSF script."
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
        -name|-N|-J) name="\$1" ; shift ;;
        -account|-A) account="\$1" ; shift ;;
        -queue|-q) queue="\$1" ; shift ;;
        -mem|-M) mem="\$1" ; shift ;;
        -walltime|-W) walltime="\$1" ; shift ;;
        -days|-dd) walltime="\$((\$1*24)):\${walltime#*:}" ; shift ;;
        -hours|-hh) walltime="\$1:\${walltime#*:}" ; shift ;;
        -minutes|-mm) walltime="\${walltime%%:*}:\$1" ; shift ;;
        -procs|-n) procs="\$1" ; shift ;;
        -nodes) nodes="\$1" ; shift ;;
        -processors-per-node|-ppn) ppn="\$1" ; shift ;;
        -mail-begin|-m-B) message="B\$message" ;;
        -mail-error|-m-N) message="N\$message" ;;
        -mail-address|-mail|-u) mail="\$1" ; shift ;;
        -no-mpi) mpi=0 ;;
        -mpi) mpi=1 ; [ \$omp -eq 1 ] && omp=0 ;;
        -no-omp) omp=0 ;;
        -omp) omp=2 ;;
        -flag-explanations|-fe) show_flag=1 ;;
        -help|-h) _s_help >&2 ; exit 0 ;;
        *)
            echo "Could not recognize flag: \$opt" >&2
            _s_help >&2; exit 1 ;;
    esac
done

# Correct for default options
[ -z "\$message" ] && message=N
[ "\$walltime" == "00:00" ] && walltime=00:15


# Check options for number of nodes vs. cores
if [ \$procs -eq 0 ]; then
  procs=\$((nodes*ppn))
fi
# Calculate number of nodes
if [ \$procs -eq 0 -a \$nodes -eq 0 -a \$ppn -gt 0 ]; then
  procs=\$ppn
  nodes=1
fi
if [ \$nodes -eq 0 -a \$ppn -gt 0 ]; then
  nodes=\$((procs/ppn))
fi
if [ \$procs -gt 0 -a \$nodes -gt 0 -a \$ppn -eq 0 ]; then
  ppn=\$((procs/nodes))
fi
if [ \$procs -eq 0 ]; then
  # The user have not specified anything, we'll use 1 core
  procs=1
  nodes=1
  ppn=1
fi
if [ \$procs -ne \$((nodes*ppn)) ]; then
  _help "The number of processors requested is not consistent: procs=\$procs != (nodes=\$nodes * \$ppn=ppn)"
  if [ \$procs -gt 0 -a \$nodes -gt 0 -a \$ppn -gt 0 ]; then
    _help "Do not mix all options --procs, --nodes and -ppn, only use 2 at a time!"
    exit 1
  fi
fi



_help "Please use \$(basename \$0) --help to see all available options."

if [ \$nodes -ge 2 ] && [ \$omp -lt 2 ]; then
  _help "Disabling OpenMP as you have requested +1 node (use -omp to force hybrid)."
  omp=0
fi

echo "#!/bin/sh"
_s_add_option -J "\$name" "The name of the LSF script"
if [ "x\$queue" != "x" ]; then
  _s_add_option -q "\$queue" "The queue the script is submitted to"
fi

_s_add_option -n "\$procs" "Total number of cores, nodes = nodes, ppn = cores used on each node => \$((nodes*ppn)) cores"

if [ \$ppn -eq \$procs ]; then
  _s_add_option -R "\"span[hosts=1]\"" "Force all processors to be on a single node"
elif [ \$ppn -gt 1 ]; then
  _s_add_message "Number of processers allocated (in blocks) per compute node => \$((nodes*ppn)) cores"
  _s_add_option -R "\"span[block=\$ppn]\"" "Assign processors in chunks and allow multiple chunks on the same node"
fi
if [ "x\$mem" != "x" ]; then
  _s_add_message "Memory allowed per processer"
  _s_add_option -R "\"rusage[mem=\$mem]\"" "Amount of memory used per core"
fi
_s_add_option -W "\$walltime" "The allowed execution time. Will quit if the execution time exceeds this limit."

case \$message in
  *B*|*b*)
     _s_add_option "-B" " " "Mail when job begins"
     ;;
esac
case \$message in
  *N*|*n*)
     _s_add_option "-N" " " "Mail when job ends"
     ;;
esac
_s_add_option -u "\$mail" "Mail address to send job information (defaulted to the mail assigned the login user)."

echo ''

_s_add_line 'module purge' "Clear list of defaulted modules"
_s_add_line 'module load dcc-setup' "Enables DCC modules"
_s_add_line 'env' "For debugging purposes"
echo ''
_s_add_line 'ulimit -s unlimited' "Ensure an unlimited stack-size"
_s_add_line 'date' "Show the date and time of execution"
echo ''

# Add typical setup for MPI/OpenMP
if [ \$mpi -eq 1 ]; then
  _help "You are using MPI. Please edit the submit-script and ensure a working MPI executable"
  if [ \$omp -gt 0 ]; then
    _help "You are creating a hybrid MPI/OpenMP script."
    _s_add_line "#unset LSB_AFFINITY_HOSTFILE" "Required for disabling OpenMPI hooks into LSF affinity settings (if it does not work, uncomment this line)"
    _s_add_line "mpirun --map-by ppr:1:socket:pe=\$ppn -x OMP_NUM_THREADS=\$ppn -x OMP_PROC_BIND=true <executable>" "Setup the MPI call to figure out the number of cores used, for 2 sockets machines you need \$((\$ppn/2))"
  else
    _help "You are creating an MPI script."
    _s_add_line 'mpirun <executable>' "Setup the MPI call, do NOT specify -np as LSF is built in"
  fi
elif [ \$omp -gt 0 ]; then
  _help "You are creating an OpenMP script (no MPI)."
  _s_add_line 'export OMP_NUM_THREADS=\$LSB_DJOB_NUMPROC' "Ensures the correct number of processes used by threading (requires BASH)"
fi

_help "Submit jobs my using (remember to pipe script into bsub): bsub < <>"
EOF

pack_cmd "mv $script $(pack_get -prefix)/bin/slsf"
unset script
