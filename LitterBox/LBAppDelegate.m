//
//  LBAppDelegate.m
//  LitterBox
//
//  Created by Cody Singleton on 9/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBAppDelegate.h"
#import "LBNearbySitesViewController.h"
#import "BlueCatsSDK.h"
#import "BCMicroLocationManager.h"
#import "FXKeychain.h"
#import "LBConstants.h"
#import "NSString+LBAdditions.h"
#import <CoreLocation/CoreLocation.h>

@implementation LBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    
    NSString *appToken = [FXKeychain defaultKeychain][LBKeychainKeyAppToken];
    if (![appToken isGuid]) {
        appToken = nil;
    }
    
    [BlueCatsSDK startPurringWithAppToken:appToken completion:^(BCStatus status) {
        if (status == kBCStatusPurringWithErrors) {
            BCAppTokenVerificationStatus appTokenVerificationStatus = [BlueCatsSDK appTokenVerificationStatus];
            if (appTokenVerificationStatus == kBCAppTokenVerificationStatusNotProvided || appTokenVerificationStatus == kBCAppTokenVerificationStatusInvalid) {
                //kBCAppTokenVerificationStatusNotProvided - Use setAppToken to set the app token.  Get an app token from app.bluecats.com
                //kBCAppTokenVerificationStatusInvalid - App token invalid.
            }
            if (![BlueCatsSDK isLocationAuthorized]) {
                [BlueCatsSDK requestAlwaysLocationAuthorization];
                //[BlueCatsSDK requestWhenInUseLocationAuthorization]; "WhenInUse" only allows beacon ranging when the app is used.
            }
            if (![BlueCatsSDK isNetworkReachable]) {
                //If this is the only error purring will be occur with network connectivity.
            }
            if (![BlueCatsSDK isBluetoothEnabled]) {
                //Prompt user to enable bluetooth in setings.  If BLE is required for current funcitonality a modal is reccomended.
            }
        }
        [[BCMicroLocationManager sharedManager] startUpdatingMicroLocation];
    }];
    
    //iOS 8.0 now requires apps to request permission to display local notifications
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LBNearbySitesViewController *sitesViewController = [[LBNearbySitesViewController alloc] init];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:sitesViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        NSString *prodName = [info objectForKey:@"CFBundleDisplayName"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:prodName
                                                        message:notification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:notification.alertAction.length > 0 ? notification.alertAction : @"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
