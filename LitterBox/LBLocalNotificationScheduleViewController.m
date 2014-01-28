//
//  LBLocalNotificationScheduleViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/18/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBLocalNotificationScheduleViewController.h"
#import "LBLocalNotificationViewController.h"
#import "BCLocalNotification.h"
#import "BCLocalNotificationManager.h"

@interface LBLocalNotificationScheduleViewController () <UITableViewDataSource, UITableViewDelegate, LBLocalNotificationViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BCLocalNotificationManager *localNotificationManager;
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UIPopoverController *addPopoverController;

@end

@implementation LBLocalNotificationScheduleViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIImageView *)emptyImageView
{
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-sites"]];
    }
    return _emptyImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    
    self.localNotificationManager = [BCLocalNotificationManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localNotificationManagerDidChangeLocalNotificationsNotification:) name:BCLocalNotificationManagerDidChangeLocalNotifications object:nil];
    
    [self.tableView reloadData];
    
    [self showEmptyViewIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.navigationItem.rightBarButtonItem = nil;
    
    self.localNotificationManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem;
    if (self.parentViewController && ![self.parentViewController isKindOfClass:[UINavigationController class]]) {
        navigationItem = self.parentViewController.navigationItem;
    }
    else {
        navigationItem = super.navigationItem;
    }
    return navigationItem;
}

- (void)showEmptyViewIfNeeded
{
    if (self.localNotificationManager.scheduledLocalNotifications.count <= 0) {
        if (![self.emptyImageView isDescendantOfView:self.tableView]) {
            
            self.tableView.userInteractionEnabled = NO;
            
            self.emptyImageView.center = self.tableView.center;
            [self.tableView addSubview:self.emptyImageView];
        }
    }
    else if ([self.emptyImageView isDescendantOfView:self.tableView]){
        [self.emptyImageView removeFromSuperview];
        self.emptyImageView.userInteractionEnabled = YES;
    }
}

- (void)add:(id)sender
{
    LBLocalNotificationViewController *viewController = [[LBLocalNotificationViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewController.delegate = self;
    viewController.site = self.site;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (!self.addPopoverController) {
            self.addPopoverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
            self.addPopoverController.popoverContentSize = CGSizeMake(320.0f, 480.0f);
        }
        
        if (!self.addPopoverController.isPopoverVisible) {
            [self.addPopoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
    }
    else {
        
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    
}

- (void)localNotificationManagerDidChangeLocalNotificationsNotification:(NSNotification *)notification
{
    [self.tableView reloadData];
    [self showEmptyViewIfNeeded];
}

- (BCLocalNotification *)scheduledLocalNotificationAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.localNotificationManager.scheduledLocalNotifications.count > indexPath.row) {
        return [self.localNotificationManager.scheduledLocalNotifications objectAtIndex:indexPath.row];
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.localNotificationManager.scheduledLocalNotifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocalNotificationCell";
    
    BCLocalNotification *localNotification = [self scheduledLocalNotificationAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [cell.textLabel setText:localNotification.alertBody];
    [cell.detailTextLabel setText:[localNotification.fireAfter description]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - LBLocalNotificationViewControllerDelegate methods

- (void)localNotificationViewControllerDelegateDidCancel:(LBLocalNotificationViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)localNotificationViewControllerDelegate:(LBLocalNotificationViewController *)viewController didSaveLocalNotification:(BCLocalNotification *)localNotification
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.tableView reloadData];
    [self showEmptyViewIfNeeded];
}

@end
