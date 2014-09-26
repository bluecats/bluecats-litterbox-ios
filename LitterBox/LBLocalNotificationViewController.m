//
//  LBLocalNotificationViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBLocalNotificationViewController.h"
#import "BCLocalNotification.h"
#import "BCLocalNotificationManager.h"
#import "LBOptionPickerViewController.h"
#import "BCSite.h"
#import "BCCategory.h"
#import "ELCTextFieldCell.h"
#import "NSDate+LBAdditions.h"
#import "BCBeacon.h"

static NSString * const kLBRightDetailCellIdentifier = @"RightDetailCell";
static NSString * const kLBTextFieldCellIdentifier = @"TextFieldCell";

@interface LBLocalNotificationViewController () <ELCTextFieldDelegate, LBOptionPickerViewControllerDelegate>

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, copy) NSString *alertBody;
@property (nonatomic, copy) NSString *alertAction;
@property (nonatomic, copy) NSDate *fireAfter;
@property (nonatomic, strong) NSArray *indexPathsOfSelectedCategories;
@property (nonatomic, strong) NSIndexPath *indexPathOfSelectedProximity;
@property (nonatomic, strong) UIBarButtonItem *saveButtonItem;

@end

@implementation LBLocalNotificationViewController

@synthesize datePicker = _datePicker;
@synthesize site = _site;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Add Notification";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    
    self.saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                        target:self
                                                                        action:@selector(save:)];
    self.saveButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.saveButtonItem;
    
    self.tableView.allowsSelection = YES;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [gestureRecognizer setCancelsTouchesInView:NO];
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

#pragma mark Private methods

- (IBAction)cancel:(id)sender
{
    [self.tableView endEditing:YES];
    
    [self.delegate localNotificationViewControllerDelegateDidCancel:self];
}

- (IBAction)save:(id)sender
{
    [self.tableView endEditing:YES];
    
    BCLocalNotification* localNotification = [[BCLocalNotification alloc] init];
    localNotification.fireAfter = self.fireAfter;
    localNotification.alertBody = self.alertBody;
    localNotification.alertAction = self.alertAction;
    localNotification.fireInSite = self.site;
    localNotification.fireInCategories = self.fireInCategories;
    localNotification.fireInProximity = self.fireInProximity;
    
    [[BCLocalNotificationManager sharedManager] scheduleLocalNotification:localNotification];
    
    [self.delegate localNotificationViewControllerDelegate:self didSaveLocalNotification:localNotification];
}

- (void)toggleSaveButton
{
    BOOL enabled = YES;
    if (self.alertBody.length <= 0) enabled = NO;
    if (!self.site) enabled = NO;
    if (self.fireInCategories.count <= 0) enabled = NO;
    if (self.fireInProximity == BCProximityUnknown) enabled = NO;
    self.saveButtonItem.enabled = enabled;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker sizeToFit];
        _datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _datePicker.minimumDate = [NSDate date];
        _datePicker.timeZone = [NSTimeZone localTimeZone];
    }
    return _datePicker;
}

- (UIToolbar *)datePickerToolbar
{
    UIToolbar* datePickerToolbar = [[UIToolbar alloc] init];
    datePickerToolbar.barStyle = UIBarStyleBlack;
    datePickerToolbar.translucent = YES;
    datePickerToolbar.tintColor = nil;
    [datePickerToolbar sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleBordered target:self
                                                                  action:@selector(datePickerDone:)];
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered target:self
                                                                    action:@selector(datePickerCancel:)];
    [datePickerToolbar setItems:[NSArray arrayWithObjects:cancelButton, doneButton, nil]];
    return datePickerToolbar;
}

- (void)datePickerDone:(id)sender
{
    [self.tableView endEditing:YES];
    self.fireAfter = self.datePicker.date;
    [self.tableView reloadData];
    [self toggleSaveButton];
}

- (void)datePickerCancel:(id)sender
{
    [self.tableView endEditing:YES];
}

- (void)setSite:(BCSite *)site
{
    _site = site;
    
    self.indexPathsOfSelectedCategories = nil;
    
    [self.tableView reloadData];
}

//- (NSArray *)fireInSites
//{
//    NSMutableArray *fireInSites = [[NSMutableArray alloc] init];
//    for (NSIndexPath *indexPath in self.indexPathsOfSelectedCategories) {
//        BCSite *site = [[self.categoriesForNearbySite allKeys] objectAtIndex:indexPath.section];
//        [fireInSites addObject:site];
//    }
//    return fireInSites;
//}

- (NSArray *)fireInCategories
{
    NSMutableArray *fireInCategories = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in self.indexPathsOfSelectedCategories) {
        [fireInCategories addObject:[self.site.cachedCategories objectAtIndex:indexPath.row]];
    }
    return fireInCategories;
}

- (BCProximity)fireInProximity
{
    if (self.indexPathOfSelectedProximity) {
        NSString *selectedProximityString = [[self proximityStringArray] objectAtIndex:self.indexPathOfSelectedProximity.row];
        return [self proximityForString:selectedProximityString];
    }
    else {
        return BCProximityUnknown;
    }
}

- (NSString *)stringForProximity:(BCProximity)proximity
{
    switch(proximity) {
        case BCProximityImmediate:
            return @"Immediate";
        case BCProximityNear:
            return @"Near";
        case BCProximityFar:
            return @"Far";
        case BCProximityUnknown:
        default:
            return @"Unknown";
    }
}

- (BCProximity)proximityForString:(NSString *)proximityString
{
    if ([proximityString isEqualToString:@"Immediate"]) {
        return BCProximityImmediate;
    }
    if ([proximityString isEqualToString:@"Near"]) {
        return BCProximityNear;
    }
    if ([proximityString isEqualToString:@"Far"]) {
        return BCProximityFar;
    }
    else {
        return BCProximityUnknown;
    }
}

- (NSArray *)proximityStringArray
{
    return @[[self stringForProximity:BCProximityImmediate], [self stringForProximity:BCProximityNear], [self stringForProximity:BCProximityFar]];
}


#pragma mark UIGestureRecognizerDelegate methods

- (void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Table view delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        
        ELCTextFieldCell *cell = (ELCTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:kLBTextFieldCellIdentifier];
        if (cell == nil) {
            cell = [[ELCTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLBTextFieldCellIdentifier];
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        
        cell.rightTextField.inputView = nil;
        cell.rightTextField.inputAccessoryView = nil;
        
        if (indexPath.row == 0) {
            cell.leftLabel.text = @"Body";
            cell.rightTextField.text = self.alertBody;
        }
        else {
            cell.leftLabel.text = @"Action";
            cell.rightTextField.text = self.alertAction;
        }
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBRightDetailCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLBRightDetailCellIdentifier];
        }
        cell.textLabel.text = @"Categories";
        
        if (self.site &&
            self.site.cachedCategories.count > 0) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", _indexPathsOfSelectedCategories.count];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            cell.detailTextLabel.text = nil;
        }
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 1) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBRightDetailCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kLBRightDetailCellIdentifier];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = @"Proximity";
        cell.detailTextLabel.text = [self stringForProximity:self.fireInProximity];
        
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 2) {
        
        ELCTextFieldCell *cell = (ELCTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:kLBTextFieldCellIdentifier];
        if (cell == nil) {
            cell = [[ELCTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kLBTextFieldCellIdentifier];
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.leftLabel.text = @"Fire After";
        cell.rightTextField.inputView = self.datePicker;
        cell.rightTextField.inputAccessoryView = self.datePickerToolbar;
        cell.rightTextField.text = [self.fireAfter stringWithMediumStyle];
        return cell;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Notification Alert";
    }
    else {
        return @"Targeting";
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1 ||
        (!self.site || self.site.cachedCategories.count <= 0)) {
        
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            LBOptionPickerViewController *viewController = [[LBOptionPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            viewController.title = @"Choose Categories";
            viewController.tableView.allowsMultipleSelection = YES;
            viewController.options = @{self.site.siteID : self.site.cachedCategories};
            [viewController selectOptionsAtIndexPaths:self.indexPathsOfSelectedCategories];
            viewController.tag = indexPath;
            viewController.delegate = self;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else if (indexPath.row == 1) {
            
            LBOptionPickerViewController *viewController = [[LBOptionPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            viewController.title = @"Choose Proximity";
            viewController.tableView.allowsMultipleSelection = NO;
            viewController.options = @{@"PROXIMITIES" : [self proximityStringArray]};
            [viewController selectOptionsAtIndexPaths:self.indexPathOfSelectedProximity ? @[self.indexPathOfSelectedProximity] : nil];
            viewController.tag = indexPath;
            viewController.delegate = self;
            
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

#pragma mark - ELCTextFieldDelegate methods

- (BOOL)textFieldCell:(ELCTextFieldCell *)inCell shouldReturnForIndexPath:(NSIndexPath *)inIndexPath withValue:(NSString *)inValue
{
    if (inIndexPath.section == 1 && inIndexPath.row == 2) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)textFieldCell:(ELCTextFieldCell *)cell updateTextLabelAtIndexPath:(NSIndexPath *)inIndexPath string:(NSString *)inValue
{
    if (inIndexPath.section == 0) {
        
        if (inIndexPath.row == 0) {
            self.alertBody = inValue;
            [self toggleSaveButton];
        }
        else if (inIndexPath.row == 1) {
            self.alertAction = inValue;
        }
    }
}

#pragma mark LBOptionPickerViewControllerDelegate methods

- (void)optionPickerViewControllerDone:(LBOptionPickerViewController *)viewController
{
    if (viewController.tag) {
        NSIndexPath *indexPath = (NSIndexPath *)viewController.tag;
        if (indexPath.section == 1 && indexPath.row == 0) {
            self.indexPathsOfSelectedCategories = viewController.indexPathsOfSelectedOptions;
            [self.tableView reloadData];
            [self toggleSaveButton];
        }
        else if (indexPath.section == 1 && indexPath.row == 1) {
            self.indexPathOfSelectedProximity = [viewController.indexPathsOfSelectedOptions lastObject];
            [self.tableView reloadData];
            [self toggleSaveButton];
        }
    }
}

@end

