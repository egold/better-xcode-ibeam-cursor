#!/bin/bash

XCODE_RESOURCE_PATH=/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources

echo 'Downloading new image'
curl -o /tmp/DVTIbeamCursor.tiff https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master/DVTIbeamCursor.tiff

echo 'Backing up the original cursor that ships with xcode to ./backup-DVTIbeamCursor.tiff'
sudo cp $XCODE_RESOURCE_PATH/DVTIbeamCursor.tiff $XCODE_RESOURCE_PATH/backup-DVTIbeamCursor.tiff

echo 'Copying the improved ibeam cursor to the correct location'
sudo cp /tmp/DVTIbeamCursor.tiff $XCODE_RESOURCE_PATH/DVTIbeamCursor.tiff

if [ -a /Applications/Xcode-beta.app ]
  then
    echo 'Replacing image for Xcode-beta as well!'
    XCODE_BETA_RESOURCE_PATH=/Applications/Xcode-beta.app/Contents/SharedFrameworks/DVTKit.framework/Resources
    sudo cp $XCODE_BETA_RESOURCE_PATH/DVTIbeamCursor.tiff $XCODE_BETA_RESOURCE_PATH/backup-DVTIbeamCursor.tiff
    sudo cp /tmp/DVTIbeamCursor.tiff $XCODE_BETA_RESOURCE_PATH/DVTIbeamCursor.tiff
    echo 'Done - restart Xcode Beta and have fun!'
fi

echo 'Removing downloaded image'
rm -f /tmp/DVTIbeamCursor.tiff

echo 'Done - restart Xcode and have fun!'
