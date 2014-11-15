#!/bin/bash

git clone https://github.com/egold/better-xcode-ibeam-cursor.git
cd better-xcode-ibeam-cursor

echo 'Backing up the original cursor that ships with xcode to ./backup-DVTIbeamCursor.tiff'
cp /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff ./backup-DVTIbeamCursor.tiff
echo 'Copying the improved ibeam cursor to the correct location'
sudo cp DVTIbeamCursor.tiff /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff
echo 'Done copying - restart Xcode and have fun!'

