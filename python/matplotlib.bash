# apt-get install libpng(12)-dev libfreetype6-dev

if [[ "x${pV:0:1}" == "x3" ]]; then
    v=3.0.3
    add_package \
	-archive matplotlib-$v.tar.gz \
	https://github.com/matplotlib/matplotlib/archive/v$v.tar.gz
else
    v=2.2.4
    add_package \
	-archive matplotlib-$v.tar.gz \
	https://files.pythonhosted.org/packages/1e/20/2032ad99f0dfe0f60970941af36e8d0942d3713f442bb3df37ac35d67358/matplotlib-$v.tar.gz
fi

pack_set -s $IS_MODULE -s $PRELOAD_MODULE

pack_set -install-query $(pack_get -LD)/python$pV/site-packages/site.py

pack_set -module-requirement numpy -module-requirement gen-freetype
for m in wxpython pyqt ; do
    if [[ $(pack_installed $m) -eq $_I_INSTALLED ]]; then
	pack_set -module-requirement $m
    fi
done


o=$(pwd_archives)/jquery-1.12.1.zip
dwn_file https://jqueryui.com/resources/download/jquery-ui-1.12.1.zip $o
pack_cmd "pushd lib/matplotlib/backends/web_backend"
pack_cmd "unzip -oq $o"
pack_cmd "popd"

if [ $(vrs_cmp $v 2.1.0) -ge 0 ]; then
    pack_cmd "sed -i -e '/__INTEL_COMPILER/s:INTEL_COMPILER:INTEL_COMPILER_DUMMY:' extern/libqhull/qhull_a.h"
else
    pack_cmd "sed -i -e '/__INTEL_COMPILER/s:INTEL_COMPILER:INTEL_COMPILER_DUMMY:' extern/qhull/qhull_a.h"
fi

#pack_cmd "unset LDFLAGS"

pack_cmd "echo '# setup.cfg' > setup.cfg"
# These directories are the directories used for searching for include
# files.
# Perhaps, when other libraries are added they should also be added here...
pack_cmd "echo '[directories]' >> setup.cfg"
pack_cmd "echo 'basedirlist = $(pack_get -prefix gen-freetype)' >> setup.cfg"
pack_cmd "echo '[test]' >> setup.cfg"
pack_cmd "echo 'local_freetype = False' >> setup.cfg"

pack_cmd "$(get_parent_exec) setup.py config"
pack_cmd "mkdir -p $(pack_get -LD)/python$pV/site-packages/"
pack_cmd "$(get_parent_exec) setup.py install --prefix=$(pack_get -prefix)"

add_test_package matplotlib.test
pack_cmd "unset LDFLAGS"
pack_cmd "pytest --pyargs matplotlib > $TEST_OUT 2>&1 ; echo 'Success'"
pack_store $TEST_OUT
