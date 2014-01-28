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

@implementation LBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        application.applicationIconBadgeNumber = 0;
    }
    
    //[FXKeychain defaultKeychain][LBKeychainKeyAppToken] = @"bc7818e0-adb0-4783-bb15-4fbedcc6a120";
    
    
    [BlueCatsSDK startPurring];
    
    NSString *appToken = [FXKeychain defaultKeychain][LBKeychainKeyAppToken];
    if ([appToken isGuid]) {
        [BlueCatsSDK setAppToken:appToken];
        [[BCMicroLocationManager sharedManager] startUpdatingMicroLocation];
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
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
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
