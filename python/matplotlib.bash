# apt-get install libpng(12)-dev libfreetype6-dev

v=2.0.0
add_package \
    --archive matplotlib-$v.tar.gz \
    https://github.com/matplotlib/matplotlib/archive/v$v.tar.gz

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set --install-query $(pack_get --LD)/python$pV/site-packages/site.py

pack_set --module-requirement numpy --module-requirement gen-freetype
for m in wxwidgets pyqt ; do
    if [[ $(pack_installed $m) -eq 1 ]]; then
	pack_set --module-requirement $m
    fi
done


pack_cmd "sed -i -e '/__INTEL_COMPILER/s:INTEL_COMPILER:INTEL_COMPILER_DUMMY:' extern/qhull/qhull_a.h"

pack_cmd "unset LDFLAGS"

pack_cmd "$(get_parent_exec) setup.py config"
pack_cmd "$(get_parent_exec) setup.py build"
pack_cmd "mkdir -p $(pack_get --LD)/python$pV/site-packages/"
pack_cmd "$(get_parent_exec) setup.py install" \
    "--prefix=$(pack_get --prefix)"

add_test_package
pack_cmd "unset LDFLAGS"
pack_cmd "nosetests --exe matplotlib > tmp.test 2>&1 ; echo 'Success'"
pack_set_mv_test tmp.test
