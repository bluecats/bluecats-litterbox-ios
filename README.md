bluecats-litterbox-ios
======================
###Here's the basics:

####BlueCats LitterBox has been updated to support iOS 8.0
If you are updating your app to support iOS 8.0, follow our [iOS 8.0 Checklist](https://github.com/bluecats/bluecats-ios-sdk/wiki/iOS-8-Checklist)

####Step 1:  clone the repo into a directory of your choosing.

####Step 2:  Prepare for pods.

- If you have never used cocoapods:
 + Follow the install instructions from cocoapods.org
 + Upon completion of the install, navigate to your repo directory and run 'pod install'
 + For all subsequent updates to this app, run 'pod update' from your directory (do not run 'pod install' a second time)
        
        
- If you have used cocoapods before:
 + Navigate to your repo directory and run 'pod install'
 + For all subsequent updates to this app, run 'pod update' from your directory (do not run 'pod install' a second time)


####Step 3:  Get your appToken from [http://app.bluecats.com/apps](http://app.bluecats.com/apps)


####Step 4:  The XCode simulator does not support BLE USB dongles...   you must debug your app on an actual device with BLE support, targeting iOS 7.0
