
create_module \
    -n python$pV.fireworks \
    -W "Nick R. Papior basic python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.fireworks/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' fireworks)


for i in $(get_index -all ase) ; do
    create_module \
	-n python$pV.ase.$(pack_get --version $i) \
	-W "Nick R. Papior ASE for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.ase.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


for i in $(get_index -all gpaw) ; do
    create_module \
	-n python$pV.gpaw.$(pack_get --version $i) \
	-W "Nick R. Papior GPAW for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.gpaw.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


for i in $(get_index -all qutip) ; do
    create_module \
	-n python$pV.qutip.$(pack_get --version $i) \
	-W "Nick R. Papior QuTip for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.qutip.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done

for i in $(get_index -all kwant) ; do
    create_module \
	-n python$pV.kwant.$(pack_get --version $i) \
	-W "Nick R. Papior kwant for: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.kwant.$(pack_get --version $i)/$(get_c) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


tmp=$(build_get --module-path)
rm -rf $tmp/python$pV.numerics/$(get_c)
tmp=
for i in scipy cython mpi4py netcdf4py matplotlib h5py numexpr sympy pandas theano sisl ; do
    if [[ $(pack_installed $i) -eq 1 ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n python$pV.numerics \
    -W "Nick R. Papior parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numerics/$(get_c) \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)
