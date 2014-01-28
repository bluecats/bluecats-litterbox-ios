//
//  LBSettingsViewController.h
//  LitterBox
//
//  Created by Cody Singleton on 11/15/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LBSettingsViewControllerDelegate;

@interface LBSettingsViewController : UIViewController

@property (nonatomic, assign) NSObject<LBSettingsViewControllerDelegate> *delegate;

@end

@protocol LBSettingsViewControllerDelegate <NSObject>

@required

- (void)settingsViewControllerDone:(LBSettingsViewController *)viewController;

@required

- (void)settingsViewController:(LBSettingsViewController *)viewController didSaveAppToken:(NSString *)appToken;

@end