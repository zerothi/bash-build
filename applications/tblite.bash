v=0.3.0
add_package https://github.com/tblite/tblite/releases/download/v$v/tblite-$v.tar.xz

pack_set -s $MAKE_PARALLEL

pack_set -install-query $(pack_get -prefix)/bin/tblite

pack_set -build-mod-req meson

tmp=""
if $(is_c intel) ; then
    tmp="$tmp $MKL_LIB -qmkl=parallel"
    
else
    la=lapack-$(pack_choice -i linalg)
    pack_set -module-requirement $la
    tmp="$(list -LD-rp-lib[omp] +$la) -lgfortran"
fi

pack_cmd "meson setup build-tmp -Dpython=true -Dpython_version=$(pack_get -prefix python)/bin/python3 --prefix=$(pack_get -prefix)"
pack_cmd "meson compile -C build-tmp"
pack_cmd "meson test -C build-tmp --print-errorlogs 2&>1 | tee test.out"
pack_cmd "meson install -C build-tmp"

pack_store test.out meson.test
