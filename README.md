
# bash-build #

Package for easy build of packages.

This package system is mainly intended for scientific use as it provides
a large variety of scientificy packages. Mainly within the field of
Density Functional Theory.

It is similar to the easy-build package, however, everything
is programmed in BASH which enables very versatile customization.

# Usage #

The most simple usage is simply to perform this:

    ./bbuild

which defines a predefined build instruction set for you.
It defaults to install every package and using optimized flags.

It defaults to install everything in the `/opt` directory. To
change the default installation directory you may pass a full
path using `--prefix <path>`:

    ./bbuild --prefix /apps/bash-build

which installs everything under `/apps/bash-build`. Note that you *MUST*
have write access to the prefix directory.


## Customizing the build ##

Defining custom builds is rather obscure and requires a more indepth knowledge
of bash-build.

First, one requires 5 specifically named generic compilation builds:

    new_build --name generic
    new_build --name generic-no-version
    new_build --name generic-empty
    new_build --name vendor
    new_build --name generic-host

Each of these have their own purpose. Basically they are all comprising
code that is installed using the system compiler suite and are thus
depending on the OS providing a basic compilation environment.
C/C++/Fortran compilers are required for these to succeed.

They are variants to control the module names and their installation
path (to separate different types of installations).

The module names can be described in this list:

1. `generic`
  - Module name consists of package name and package version
  - Installation path consists of package name and package version
2. `generic-no-version`
  - Module name consists of package name
  - Installation path consists of package name
3. `generic-empty`
  - Module name consists of package name
  - Installation path is in the top directory (mainly used for packages which themselves add their package name)
4. `vendor`
  - Module name consists of package name and package version
  - Installation path consists of vendor (as is), package name and package version
5. `generic-host`
  - Module name consists of package name, package version and compiler version
  - Installation path consists of package name, package version and compiler version

These are typically not needed to be changed but if you provide a build instruction
they must be defined by you.  
For inspiration you may copy this from `build-examples/build-generic.sh`.

Then you should define your default build environment for the optimized compilation
instructions.  
For inspiration you may copy this from `build-examples/build-gnu.sh`.


## Recreating the default build ##

To recreate the default build installation you should copy these files to the top-directory:

    cp build-examples/source-generic.sh .
    cp build-examples/source-gnu.sh .
    cp build-examples/source-gnu-debug.sh .
    cp build-examples/build-generic.sh .
    cp build-examples/build-gnu.sh .

Then you may run the installation as:

    ./bbuild build-gnu.sh


# Requirements #

To utilize bash-build you rely on the environment module package, see [here][env-mod] for the package.
It is not a requirement that you install it, bash-build will install it as the first thing, and you may
use this as the requirement.

NOTE: Even though it is an installation requirement, it is _not_ a usage
requirement. Hence you may use [Lmod][lmod] subsequently to the installation.

bash-build will check that the modules function is available for the installation.
If not it will install the environment modules and die, telling you to add that package
to your `.bashrc` source.

After you have done this, you may rerun the installation script.

Secondly, you also need to add the different module paths to the module
enviroment.
bash-build will also inform you whether the required module paths are in the
MODULEPATH environment (this env-var contains the paths where modules are searched for).
Basically what you need to add to your `.bashrc` is the following:

If you do not have environment modules installed you should add this to your `.bashrc`

    source /opt/generic/modules/Modules/default/init/bash

Change `/opt` with your installation directory.

Subsequently you should add these paths to the module enviroment

    module use --append /opt/modules-generic
    module use --append /opt/modules
    module use --append /opt/modules-npa
    module use --append /opt/modules-npa-apps

Again, change `/opt` accordingly.


## Contributions, issues and bugs ##

I would advice any users to contribute as much feedback and/or PRs to further
maintain and expand this installation script.

Please do not hesitate to contribute!

If you find any bugs please form a [bug report/issue][issue].

If you have a additions please consider adding a [pull request][pr].


## License ##

The bash-build license is [LGPL][lgpl], please see the LICENSE file.


<!---
Links to external and internal sites.
-->
[bb@git]: https://github.com/zerothi/bash-build
[issue]: https://github.com/zerothi/bash-build/issues
[pr]: https://github.com/zerothi/bash-build/pulls
[lgpl]: http://www.gnu.org/licenses/lgpl.html
[env-mod]: http://modules.sourceforge.net/
[lmod]: https://github.com/TACC/Lmod
