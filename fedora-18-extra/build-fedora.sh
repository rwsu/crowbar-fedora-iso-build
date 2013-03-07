#!/bin/bash

cd ../barclamps/crowbar/
git checkout crowbar.yml
cd ../../barclamps/provisioner/
git checkout crowbar.yml
cd ../../fedora-18-extra
cp redhat-common-build_lib.sh ../redhat-common/build_lib.sh
git add ../redhat-common/build_lib.sh

../dev build --os fedora-18 --wild-cache 2>&1 | tee /home/rwsu/crowbar-iso-build.log
