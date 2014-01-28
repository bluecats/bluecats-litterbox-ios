//
//  LBSiteDetailViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBSiteDetailViewController.h"
#import "LBLocalNotificationScheduleViewController.h"
#import "LBMicroLocationViewController.h"

@interface LBSiteDetailViewController () <UIToolbarDelegate>

@property (nonatomic, strong) LBMicroLocationViewController *microLocationViewController;
@property (nonatomic, strong) LBLocalNotificationScheduleViewController *localNotificationScheduleViewController;
@property (nonatomic, weak, readonly) UIViewController *selectedViewController;

- (NSArray *)toolbarItems;

@end

@implementation LBSiteDetailViewController

- (NSArray *)toolbarItems
{
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:self
                                                                                   action:nil];
    
    UIBarButtonItem *microLocationButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"µLocation"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(showMicroLocation:)];
    
    UIBarButtonItem *localNotificationScheduleButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notifications"
                                                                                     style:UIBarButtonItemStylePlain
                                                                                    target:self
                                                                                    action:@selector(showLocalNotificationSchedule:)];
    
    return @[flexibleSpace, microLocationButtonItem, flexibleSpace, localNotificationScheduleButtonItem, flexibleSpace];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cathead-logo"]];
    
    [self setToolbarItems:self.toolbarItems animated:NO];
    
    self.microLocationViewController = [[LBMicroLocationViewController alloc] init];
    self.microLocationViewController.site = self.site;
    
    self.localNotificationScheduleViewController = [[LBLocalNotificationScheduleViewController alloc] init];
    self.localNotificationScheduleViewController.site = self.site;
    
    [self setSelectedViewController:self.microLocationViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)setSelectedViewController:(UIViewController *)toViewController
{
	UIViewController *fromViewController = _selectedViewController;
    
    if (fromViewController == toViewController) return;
    
    if (fromViewController) {
        [fromViewController willMoveToParentViewController:nil];
    }
    
    [self addChildViewController:toViewController];
    
    if (fromViewController) {
        
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:0.0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^ {
//                                    fromViewController.view.alpha = 0.0;
//                                    toViewController.view.alpha = 1.0;
                                }
                                completion:^(BOOL finished) {
                                    [fromViewController removeFromParentViewController];
                                    [toViewController didMoveToParentViewController:self];
                                    _selectedViewController = toViewController;
                                }
         ];
    }
    else {
        
//        toViewController.view.alpha = 1.0;
        [self.view addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        
        _selectedViewController = toViewController;
    }
}

- (void)showLocalNotificationSchedule:(id)sender
{
    [self setSelectedViewController:self.localNotificationScheduleViewController];
}

- (void)showMicroLocation:(id)sender
{
    [self setSelectedViewController:self.microLocationViewController];
}

@end
