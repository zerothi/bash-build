add_package -build generic -package jdk -version $v.$u \
   -directory jdk-${v}.${u} \
   https://download.oracle.com/java/${v}/archive/jdk-${v}.${u}_linux-x64_bin.tar.gz

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/java

pack_cmd "mkdir -p $(pack_get -prefix)"
pack_cmd "mv ./* $(pack_get -prefix)/"
