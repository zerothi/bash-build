tmp=$(hostname)
[ "${tmp:0:2}" != "n-" ] && return 0

for v in 1.1 1.2 ; do
add_package http://www.wannier.org/code/wannier90-$v.tar.gz

pack_set -s $MAKE_PARALLEL -s $IS_MODULE

pack_set --install-query $(pack_get --install-prefix)/bin/wannier90.x

# Check for Intel MKL or not
tmp=$(get_c)
if [ "${tmp:0:5}" == "intel" ]; then
    tmp="-mkl=sequential $MKL_PATH/lib/intel64/libmkl_lapack95_lp64.a $MKL_PATH/lib/intel64/libmkl_blas95_lp64.a"
elif [ "${tmp:0:3}" == "gnu" ]; then
    pack_set --module-requirement atlas
    tmp=$(pack_get --install-prefix atlas)/lib
    tmp="$tmp/liblapack_atlas.a $tmp/libcblas.a $tmp/libf77blas.a $tmp/libatlas.a"
fi

cat << EOF > $(pack_get --alias)-$(pack_get --version).sys
F90 = $FC
FCOPTS = $FCFLAGS $tmp
LDOPTS = $FCFLAGS $tmp
LIBS = $tmp -lpthread
EOF
pack_set --command "cp $(pwd)/$(pack_get --alias)-$(pack_get --version).sys make.sys"
pack_set --command "rm $(pwd)/$(pack_get --alias)-$(pack_get --version).sys"


# Make commands
pack_set --command "make $(get_make_parallel) wannier"
pack_set --command "make lib"
pack_set --command "make test"
pack_set --command "mkdir -p $(pack_get --install-prefix)/bin/"
pack_set --command "cp wannier90.x $(pack_get --install-prefix)/bin/"
pack_set --command "mkdir -p $(pack_get --install-prefix)/lib/"
pack_set --command "cp libwannier.a $(pack_get --install-prefix)/lib/"

pack_install


old_path=$(get_module_path)
set_module_path $install_path/modules-npa-apps

tmp_load=""
for cmd in $(pack_get --module-requirement) ; do
    tmp_load="$tmp_load -L \"$(pack_get --module-name $cmd)\""
done

create_module \
    -n "\"Nick Papior Andersen's script for loading $(pack_get --package): $(get_c)\"" \
    -v $(pack_get --version) \
    -M $(pack_get --alias).$(pack_get --version).$(get_c) \
    -P "/directory/should/not/exist" $tmp_load \
    -L $(pack_get --module-name)

set_module_path $old_path

done