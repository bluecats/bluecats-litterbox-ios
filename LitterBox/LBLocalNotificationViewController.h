//
//  LBLocalNotificationViewController.h
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCLocalNotification, BCSite;

@protocol LBLocalNotificationViewControllerDelegate;

@interface LBLocalNotificationViewController : UITableViewController

@property (nonatomic, assign) NSObject<LBLocalNotificationViewControllerDelegate> *delegate;
@property (nonatomic, copy) BCSite *site;

@end


@protocol LBLocalNotificationViewControllerDelegate <NSObject>

@required

- (void)localNotificationViewControllerDelegateDidCancel:(LBLocalNotificationViewController *)viewController;

- (void)localNotificationViewControllerDelegate:(LBLocalNotificationViewController *)viewController didSaveLocalNotification:(BCLocalNotification *)localNotification;

@end