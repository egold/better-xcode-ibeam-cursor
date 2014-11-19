#!/bin/bash

echo 'Downloading new image'
curl -o /tmp/DVTIbeamCursor.tiff https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master/DVTIbeamCursor.tiff

echo 'Backing up the original cursor that ships with xcode to ./backup-DVTIbeamCursor.tiff'
cp /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff ./backup-DVTIbeamCursor.tiff
echo 'Copying the improved ibeam cursor to the correct location'
sudo cp /tmp/DVTIbeamCursor.tiff /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff

echo 'Removing downloaded image'
rm -f /tmp/DVTIbeamCursor.tiff

echo 'Done - restart Xcode and have fun!'
