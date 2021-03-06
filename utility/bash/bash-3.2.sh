#!/bin/bash

# Copyright (C) 2019  Red Hat, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Downloads and runs bash 3.2 in the current directory.

# tested on fc23-fc30 x86_64

# exit on empty variables
set -u

# exit on non-zero status
set -e

mkdir -p bash-3.2-centos-5.9
cd bash-3.2-centos-5.9 || exit 4

# download rpms
if [ ! -f bash-3.2-32.el5.x86_64.rpm ]; then
    # output is force-redirected to the specified file name so that MITM cannot pollute other files/directories
    wget -O bash-3.2-32.el5.x86_64.rpm http://vault.centos.org/5.9/os/x86_64/CentOS/bash-3.2-32.el5.x86_64.rpm || { echo "download error"; exit 3; }
fi
if [ ! -f libtermcap-2.0.8-46.1.x86_64.rpm ]; then
    # output is force-redirected to the specified file name so that MITM cannot pollute other files/directories
    wget -O libtermcap-2.0.8-46.1.x86_64.rpm http://vault.centos.org/5.9/os/x86_64/CentOS/libtermcap-2.0.8-46.1.x86_64.rpm || { echo "download error"; exit 3; } 
fi

# integrity check rpms

if [[ "$(sha256sum "bash-3.2-32.el5.x86_64.rpm")" != "24a3babc71e986bcdd343a3a5c5f14b99f8b6e4248e60d50715fd6839e5e589c  bash-3.2-32.el5.x86_64.rpm" ]]; then
    echo "integrity fail - bash-3.2-32.el5.x86_64.rpm"
    exit 2
fi
if [[ "$(sha256sum "libtermcap-2.0.8-46.1.x86_64.rpm")" != "753f452aa71ca95b8fd0ccb10fe573fea7d41ff9d40d51f70369a81de0c35aef  libtermcap-2.0.8-46.1.x86_64.rpm" ]]; then
    echo "integrity fail - libtermcap-2.0.8-46.1.x86_64.rpm"
    exit 2
fi

# unpack rpms
if [ ! -d ./bin ]; then
    rpm2cpio bash-3.2-32.el5.x86_64.rpm | cpio -i --make-directories
fi
if [ ! -d ./lib64 ]; then
    rpm2cpio libtermcap-2.0.8-46.1.x86_64.rpm | cpio -i --make-directories
fi

# sanity check
if [ ! -d ./lib64 ]; then
    echo "Directory ./lib64 doesn't exist."
    exit 1
fi
if [ ! -f ./bin/bash ]; then
    echo "File ./bin/bash doesn't exist."
    exit 1
fi

# set variables so that bash executes and doesn't pollute the user's home
if [[ ${LD_LIBRARY_PATH:-} ]]; then
    # exists, so append to it
    export LD_LIBRARY_PATH
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/lib64
else
    # doesnt exist, so create it
    export LD_LIBRARY_PATH
    LD_LIBRARY_PATH=$(pwd)/lib64
fi
echo "LD_LIBRARY_PATH set to $LD_LIBRARY_PATH"
mkdir -p home/test
export HOME
HOME=$(pwd)/home/test
echo "HOME set to $HOME"
export SHELL
SHELL=$(pwd)/bin/bash
echo "SHELL set to $SHELL"
export PATH
PATH=$(pwd)/bin:$PATH
echo "PATH set to $PATH"

cat > "$(pwd)/bin/man" << EOF
#!/bin/env bash
/usr/bin/man "$(pwd)/usr/share/man/man1/""\$1"".1.gz"
EOF

chmod a+x "$(pwd)/bin/man"

echo "Note: you can run man bash to read the man page for bash 3.2."

echo "Starting bash 3.2"
bin/bash
