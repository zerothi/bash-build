if ! $(is_c intel) ; then
    return
fi

if [[ $(pack_get --installed vasp) -eq 0 ]]; then
    return
fi
unset tmp_start tmp_end

function tmp_start {
    if [[ $(vrs_cmp $1 5.3.5) -ge 0 ]]; then
	add_package \
	    --build generic \
	    --no-default-modules \
	    --package vasp/POTCARS \
	    --directory vasp \
	    --version $2 \
	    http://www.student.dtu.dk/~nicpa/packages/vasp-$1.tar
    else
	add_package \
	    --build generic \
	    --no-default-modules \
	    --package vasp/POTCARS \
	    --directory VASP \
	    --version $2 \
	    http://www.student.dtu.dk/~nicpa/packages/VASP-$1.zip
    fi

    pack_set -s $IS_MODULE

    pack_set --host-reject ntch
    pack_set --host-reject zeroth
    pack_set --prefix-and-module \
	$(pack_get --alias)/$1/$2
    pack_set --module-opt "--lua-family vasp-potcar"
    pack_cmd "mkdir -p $(dirname $(pack_get --prefix))"
    pack_cmd "rm -rf $(pack_get --prefix)"
    pack_cmd "mkdir tmp"
    pack_cmd "cd tmp"

}    

function tmp_end {
    pack_cmd "cd ../"
    # The file permissions are not expected to be correct (we correct them
    # here)
    pack_cmd "chmod 0644 tmp/*/*"
    pack_cmd "mv tmp $(pack_get --prefix)"
    pack_set --module-opt "--set-ENV POTCARS=$(pack_get --prefix)"
    # We only check for one
    pack_set --install-query $(pack_get --prefix)/$3
    pack_install
}

v=5.3.3
for version in LDA LDA.52 PBE PBE.52 ; do
    tmp_start $v $version
    pack_cmd "tar xfz ../potpaw_$version.t*"
    tmp_end $v $version H/POTCAR
done

v=5.3.5
tmp_start $v GGA
pack_cmd "tar xfz ../potpaw_GGA.t*"
tmp_end $v GGA H/POTCAR.Z
for version in GGA LDA ; do
    tmp_start $v USPP_$version
    pack_cmd "tar xfz ../potUSPP_$version.t*"
    tmp_end $v USPP_$version H_soft/POTCAR.Z
done

unset tmp_start tmp_end
