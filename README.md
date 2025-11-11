# Yoonu Njub

A streaming and downloading audio project for the Yoonu Njub radio program.

Web version at http://yoonunjub.sng.al

## What's new?

### 1.2

- Fast-forward and rewind via buttons & double tap left or right side of image 
- Revised player controls
- Correction of translation strings
- Update to Flutter 3 & Android and iOS current SDK versions

### 1.1

Update to Flutter 2.0:

- null safety
- new color scheming
- various breaking changes fixed

Other:

- Update to Flutter's new internationalization method
- Episode audio showed up as 0:00 before play and then went to full time - now only shows duration after playback begins
- Startup refinements for effeciency
- New notification area playback controls for iOS and Android
- New error catching and reporting on 'audio not found' errors for streaming and download functions
- Check all shows and report errors function (tap below content on settings screen six times)
- Updated 'contact us' options
- HTML collapsible docs for About and Licensing pages
- Material 3 theming


### 1.2
- UI revision

### 1.2.1
- Updating to Android 15/API 35
- Released this version to Android only, not iOS or web

### 1.3.0
- Rewrote the playlist handling to solve several problems
- Rewrote the download tracking and notifying
- Added QR share
- SharedPreferences >> Hive for settings
- Share audio directly to messaging apps
- playlist improvements
- September 10 2025

### 1.3.2
- status bar and menu button now change based on background picture

## Web release
>>increment build number in pubspec.yaml
rm -rf build/web
flutter build web 
cd build/web
HASH=$(sha256sum main.dart.js | cut -c1-8)
mv main.dart.js main.dart.$HASH.js
sed -i .bak "s/main.dart.js/main.dart.$HASH.js/g" flutter_bootstrap.js 
rm flutter_bootstrap.js.bak 