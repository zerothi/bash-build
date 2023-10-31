v=1.8.0
u=391
add_package -build generic -package jre -version $v.$u \
   -directory jre${v}_${u} \
   -archive jre-${v}u${u}-linux-x64.tar.gz \
   "https://sdlc-esd.oracle.com/ESD6/JSCDL/jdk/8u391-b13/b291ca3e0c8548b5a51d5a5f50063037/jre-8u391-linux-x64.tar.gz?GroupName=JSC&FilePath=/ESD6/JSCDL/jdk/8u391-b13/b291ca3e0c8548b5a51d5a5f50063037/jre-8u391-linux-x64.tar.gz&BHost=javadl.sun.com&File=jre-8u391-linux-x64.tar.gz&AuthParam=1698758253_2b68ec31f7b55ef47c995454815da295&ext=.gz"

pack_set -s $IS_MODULE

pack_set -install-query $(pack_get -prefix)/bin/java

pack_cmd "mkdir -p $(pack_get -prefix)"
pack_cmd "mv ./* $(pack_get -prefix)/"
