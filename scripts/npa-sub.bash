
_npa_new_name
cat <<EOF > $script
# This creates a function for 
# easier submission with respect to names

function sub {
   local name=
   local tmp=$(pwd)
   local i=0
   case $1 in 
     +*)
       let i=${#1}
       # Get current directory
       tmp=$(pwd)
       name="$(basename $tmp)"
       tmp=$(dirname $tmp)
       let i--
       while [[ $i -gt 0 ]]; do
          name="$(basename $tmp):$name"
          tmp=$(dirname $tmp)
          let i--
       done
       shift
       ;;
   esac
   if [[ -z "$name" ]]; then
     qsub $@
   else
     qsub $@ -N "$name"
   fi
}

EOF

pack_cmd "mv $(pwd)/$script $(pack_get --prefix)/source/sub.bashrc"
