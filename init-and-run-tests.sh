#!/bin/bash
set -e

GODOT_VERSION=$1
GUT_PARAMS=$2

# # Download Godot
wget https://downloads.tuxfamily.org/godotengine/4.0/rc6/mono/Godot_v4.0-rc6_mono_linux_x86_64.zip

# Unzip it
unzip Godot_v4.0-rc6_mono_linux_x86_64.zip
mv Godot_v4.0-rc6_mono_linux_x86_64 /usr/local/bin/godot

#
# Launch the tests
#

# This is needed to test this Docker image
if [ -f "test-project/project.godot" ]
then
  cd test-project
fi

echo Running GUT tests using params:
echo "  -> $GUT_PARAMS"

TEMP_FILE=/tmp/gut.log
/usr/local/bin/godot -s --path $PWD addons/gut/gut_cmdln.gd -gexit $GUT_PARAMS 2>&1 | tee $TEMP_FILE
# /usr/local/bin/godot -d -s
# $PWD/addons/gut/gut_cmdln.gd -gexit $GUT_PARAMS 2>&1 | tee $TEMP_FILE

cat $TEMP_FILE

# Godot always exists with error 0, but we want this action to fail in case of errors
if grep -q "No tests ran" "$TEMP_FILE";
then
  echo "No test ran. Please check your 'gut_params'"
  exit 1
fi

if  grep -q "[Failed]:" "$TEMP_FILE"
then
  echo "One or more test have failed"
  exit 1
fi

echo "ALL GOOD :) :) :)"

exit 0
