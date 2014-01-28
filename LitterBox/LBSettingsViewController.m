//
//  LBSettingsViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/15/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBSettingsViewController.h"
#import "NSString+LBAdditions.h"
#import "FXKeychain.h"
#import "LBConstants.h"

static NSString * const kLBAppTokenCellIdentifier = @"AppTokenCell";

@interface LBSettingsViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LBSettingsViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(done:)];
    
    if ([self secureAppToken].length <= 0) self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (void)done:(id)sender
{
    [self.delegate settingsViewControllerDone:self];
}

- (NSString *)secureAppToken
{
    NSString *appToken =  [FXKeychain defaultKeychain][LBKeychainKeyAppToken];
    if (appToken.length == 36) {
        return [NSString stringWithFormat:@"...%@", [appToken substringFromIndex:32]];
    }
    return nil;
}

- (void)saveAppToken:(NSString *)appToken
{
    [FXKeychain defaultKeychain][LBKeychainKeyAppToken] = appToken;
    
    [self.tableView reloadData];
    
    self.navigationItem.leftBarButtonItem.enabled = YES;
    
    if ([self.delegate respondsToSelector:@selector(settingsViewController:didSaveAppToken:)]) {
        
        [self.delegate settingsViewController:self didSaveAppToken:appToken];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBAppTokenCellIdentifier];
        if (!cell) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:kLBAppTokenCellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        cell.textLabel.text = @"App Token";
        cell.detailTextLabel.text = [self secureAppToken];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return @"In order to make authorized requests to BlueCats' API, your app needs an app token that can be obtained from bluecats.com.";
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"BlueCats App Token"
                                                          message:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Save", nil];
        alertView.delegate = self;
        [alertView setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [alertView show];

    }
}

#pragma mark - UIAlertViewDelegate methods

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *textField = [alertView textFieldAtIndex:0];
    if ([textField.text isGuid]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Save"])
    {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if (textField) {

            [self saveAppToken:textField.text];
        }
    }
}

@end
