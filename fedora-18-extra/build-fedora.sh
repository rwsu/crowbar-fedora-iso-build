#!/bin/bash

# rpms non the in Fedora Install DVD
if [[ ! -f MAKEDEV-3.24-11.fc18.x86_64.rpm ]]; then
    wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/m/MAKEDEV-3.24-11.fc18.x86_64.rpm
fi

if [[ ! -f libnih-1.0.2-7.fc18.x86_64.rpm ]]; then
wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/l/libnih-1.0.2-7.fc18.x86_64.rpm
fi

if [[ ! -f mcstrans-0.3.3-6.fc18.x86_64.rpm ]]; then
wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/m/mcstrans-0.3.3-6.fc18.x86_64.rpm
fi

if [[ ! -f mingetty-1.08-11.fc18.x86_64.rpm ]]; then
wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/m/mingetty-1.08-11.fc18.x86_64.rpm
fi

if [[ ! -f procps-ng-3.3.3-2.20120807git.fc18.x86_64.rpm ]]; then
wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/p/procps-ng-3.3.3-2.20120807git.fc18.x86_64.rpm
fi

if [[ ! -f util-linux-2.22.1-2.1.fc18.x86_64.rpm ]]; then
wget http://mirror.chpc.utah.edu/pub/fedora/linux/releases/18/Everything/x86_64/os/Packages/u/util-linux-2.22.1-2.1.fc18.x86_64.rpm
fi

cp redhat-common-build_lib.sh ../redhat-common/build-lib.sh

../dev build --os fedora-18 --wild-cache 2>&1 | tee ../crowbar-iso-build.log
