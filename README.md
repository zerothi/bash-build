
bash-build
==========

Package for easy build of packages.

It is similar to the easy-build package, however, everything
is programmed in BASH which enables very versatile customization.


Usage
=====

The most simple usage can be done following these steps.

    1. Copy the source files that describes the compilation options
    2. Copy the build files that describes the build-system.
    3. Start the installation.

The basic source files are located in the `build-examples` directory.

To copy them do:

    cp build-examples/source-generic.sh .
    cp build-examples/source-gnu.sh .
    cp build-examples/source-gnu-debug.sh .

To copy the controlling build files do:

    cp build-examples/build-generic.sh .
    cp build-examples/build-gnu.sh .

Please edit the build files to control the installation path of
both the modules and the packages.

To start the installation you simply run the `install.sh` script.

    ./install.sh build-gnu.sh -d gnu

which sources the `build-gnu.sh` file and adds the settings defined in the
`build-gnu.sh` file to the build system. Note that the top line in `build-gnu.sh`
contains `source build-generic.sh`.

The flag `-d gnu` sets the default build system to be the build system called `gnu`.
In this case the `gnu` build system is defined in the `build-gnu.sh` file and
uses more aggressive optimizations than the `generic` build.

NOTE:
The first time you install packages it is really important to have the
`module` command available. Secondly you need to have the module installation
paths added to the `module` path.

if you do not have the `module` command installed you need to start the
installation and kill it after having installed the `module` command.

Basically what you need to add to your `.bashrc` is the following:

    source /opt/generic/modules/Modules/default/init/bash
    module use --append /opt/modules-generic
    module use --append /opt/modules-vendor
    module use --append /opt/modules
    module use --append /opt/modules-npa
    module use --append /opt/modules-npa-apps

If you change the default module path installation please alter
the above paths to your module paths.


    

