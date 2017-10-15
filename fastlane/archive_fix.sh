#!/bin/bash

# navigate to latest archive created
cd ~/Library/Developer/Xcode/Archives
foo=$(ls -t | head -n1) && cd $foo
line=$(ls -t | head -n1) && cd "$line"

# bug fix
find Products/ -name Info.plist -print0 | xargs -0n1 plutil -replace BuildMachineOSBuild -string 16A323