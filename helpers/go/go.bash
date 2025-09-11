add_package -build generic -package go -version $v.$u \
   -directory go \
   https://go.dev/dl/go${v}.${u}.linux-amd64.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/go

pack_cmd "mkdir -p $(pack_get -prefix)"
pack_cmd "mv ./* $(pack_get -prefix)/"
