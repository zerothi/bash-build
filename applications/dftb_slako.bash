add_package \
    --build generic \
    --no-default-modules \
    --package dftb-slako \
    --directory slako \
    http://www.dftb.org/fileadmin/DFTB/public/slako-unpacked.tar.xz

pack_set -s $IS_MODULE
pack_set --host-reject zeroth

pack_set_file_version

pack_set --install-query $(pack_get --prefix)/3ob

pack_cmd "mkdir -p $(pack_get --prefix)"

pack_cmd "chmod 0755 -R ./"
# Make files readable, but not executable
pack_cmd 'find . -type f -exec chmod 444 {} \;'
pack_cmd "for d in */ ; do mv \$d $(pack_get --prefix)/ ; done"

pack_set --module-opt "--set-ENV DFTB_SLAKO_DIR=$(pack_get --prefix)"
