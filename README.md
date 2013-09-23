bluecats-litterbox-ios
======================
##Here's the basics:


Step 1:  clone the repo into a directory of your choosing.

Step 2:  Prepare for pods.
    If you have never used cocoapods:
        a.  Follow the install instructions from cocoapods.org
        b.  Upon completion of the install, navigate to your repo directory and run 'pod install'
        c.  For all subsequent updates to this app, run 'pod update' from your directory (do not run 'pod install' a second time)
        
        
    If you have used cocoa pods before:
        a.  Navigate to your repo directory and run 'pod install'
        b.  For all subsequent updates to this app, run 'pod update' from your directory (do not run 'pod install' a second time)


Step 3:  Request a BCAppToken from theteam@bluecats.com

Step 4:  In  LBAppDelegate.m, replace @"YourBCAppToken" with your BCAppToken

``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [BlueCatsSDK setOptions:@{BCOptionUseStageApi: @"YES"}];
    [BlueCatsSDK startPurringWithAppToken:@"YourBCAppToken"];
    [[BCMicroLocationManager sharedManager] startUpdatingMicroLocation];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    LBOnlyViewController *onlyViewController = [[LBOnlyViewController alloc] init];
    self.window.rootViewController = onlyViewController;
    [self.window makeKeyAndVisible];
    return YES;
}
```


Step 5:  The XCode simulator does not support BLE without special dongles and special settings...   you must debug your app on an actual device with BLE support, targeting iOS 6.1 or iOS 7.0
