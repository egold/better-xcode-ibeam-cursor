Better Xcode ibeam cursor
=================

Better i-beam (text cursor) for Xcode for dark background / light text color themes.

## Important note for Xcode 7.3+ users!

The file that controls the i-beam cursor is no longer a flat .tiff file, but rather part of an assets bundle called Assets.car. Please see [issue #16's thread](https://github.com/egold/better-xcode-ibeam-cursor/issues/16) for a manual workaround. Thanks go out to @cjheng, @allen-zeng, @sokobania, and @ebaker355 for helping find and solve the issue. I'm looking forward to getting this working in an automated way in the future.


## Directions for pre-7.3 versions of Xcode

### Directions:

##### The easy way

```bash
curl -L https://raw.githubusercontent.com/egold/better-xcode-ibeam-cursor/master/install.sh | bash
```

##### The manual way

###### For Xcode 7.2.1 and earlier:

1. Clone this repository (or fork it if you want to customize the tiff yourself!)
2. Create a backup of `/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff`
3. Copy (`sudo cp`) the tiff to `/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/DVTIbeamCursor.tiff`
4. Restart Xcode

###### For Xcode 7.3 and later:

1. Clone this repository (the lines below assume you've cloned to your home directory)
2. Create a backup of `/Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources/Assets.car`
3. Patch the Assets.car file with the appropriate patch:
```
cd /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework/Resources
sudo bspatch Assets.car Assets.car ~/better-xcode-ibeam-cursor/patches/Assets.car-Xcode-7.3.bspatch
```
4. Restart Xcode

You should now have an i-beam that is more easy to see on a dark or black background.

Before:

![Original Xcode Ibeam](https://raw.github.com/egold/better-xcode-ibeam-cursor/master/cursor-example-before.png "Original Xcode Ibeam")

After:

![Improved Xcode Ibeam](https://raw.github.com/egold/better-xcode-ibeam-cursor/master/cursor-example-after.png "Replacement Xcode Ibeam")

### Background

I find it more enjoyable to code with the Midnight color theme in Xcode, but found myself always hunting for the cursor, especially on a large monitor. I found a pretty good TIFF someone created, so I cleaned up a bit of the outline thickness and posted it here!
