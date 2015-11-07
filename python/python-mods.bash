
create_module \
    -n "Nick R. Papior basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.fireworks/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' fireworks)


for i in $(get_index -all ase) ; do
    create_module \
	-n "Nick R. Papior ASE for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.ase.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


for i in $(get_index -all gpaw) ; do
    create_module \
	-n "Nick R. Papior GPAW for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.gpaw.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


tmp=$(build_get --module-path)
rm -rf $tmp/python$pV.numerics/$(get_c)
tmp=
for i in scipy cython mpi4py netcdf4py matplotlib h5py numexpr sympy pandas theano sids ; do
    if [[ $(pack_installed $i) -eq 1 ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n "Nick R. Papior parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numerics/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)
