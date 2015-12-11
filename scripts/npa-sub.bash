
_npa_new_name
cat <<EOF > $script
# This creates a function for 
# easier submission with respect to names

function sub {
   local name=
   local dir=\$(pwd)
   local i=0
   case \$1 in 
     +*)
       let i=\${#1}
       # Get current directory
       dir=\$(pwd)
       name="\$(basename \$dir)"
       dir=\$(dirname \$dir)
       let i--
       while [[ \$i -gt 0 ]]; do
          name="\$(basename \$dir):\$name"
          dir=\$(dirname \$dir)
          let i--
       done
       shift
       ;;
   esac
   if [[ -z "\$name" ]]; then
     qsub \$@
   else
     qsub \$@ -N "\$name"
   fi
}

EOF

pack_cmd "mv $(pwd)/$script $(pack_get --prefix)/source/sub.bashrc"
