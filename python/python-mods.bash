
create_module \
    -n python$pV.fireworks \
    -W "Python: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.fireworks \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' fireworks)


for i in $(get_index -all gpaw) ; do
    create_module \
	-n python$pV.gpaw.$(pack_get --version $i) \
	-W "GPAW: $(get_c)" \
	-v $(date +'%g-%j') \
	-M python$pV.gpaw.$(pack_get --version $i) \
	-P "/directory/should/not/exist" \
	$(list --prefix '-RL ' $i)
done


case $_mod_format in
    $_mod_format_ENVMOD)
	function rm_latest {
	    local latest_mod=$(build_get --module-path)
	    rm -rf $latest_mod/$1
	}
	;;
    $_mod_format_LMOD)
	function rm_latest {
	    local latest_mod=$(build_get --module-path)
	    rm -rf $latest_mod/$1.lua
	}
	;;
esac

rm_latest python$pV.numerics
tmp=
for i in scipy cython mpi4py netcdf4py matplotlib sympy pandas \
	       h5py numexpr theano numba seaborn networkx \
	       kwant pybinding phonopy pythtb qutip ase \
	       dask distributed xarray yt \
	       pyamg scikit-learn scikit-nano scikit-optimize \
	       orthopy quadpy lmfit tensorflow \
	       Inelastica-dev ipi-dev sisl-dev hotbit-dev ; do
    if [[ $(pack_installed $i) -eq $_I_INSTALLED ]]; then
        tmp="$tmp $i"
    fi
done
create_module \
    -n python$pV.numerics \
    -W "Parallel python script for: $(get_c)" \
    -v $(date +'%g-%j') \
    -M python$pV.numerics \
    -P "/directory/should/not/exist" \
    $(list --prefix '-RL ' $tmp)

unset rm_latest
