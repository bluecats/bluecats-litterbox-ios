//
//  LBNearbySitesViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 11/14/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBNearbySitesViewController.h"
#import "BCSite.h"
#import "BCMicroLocationManager.h"
#import "OrderedDictionary.h"
#import "LBSiteDetailViewController.h"
#import "LBSettingsViewController.h"
#import "FXKeychain.h"
#import "LBConstants.h"
#import "NSString+LBAdditions.h"
#import "BlueCatsSDK.h"

static NSString * const kLBSiteCellIdentifier = @"SiteCell";

@interface LBNearbySitesViewController () <UITableViewDataSource, UITableViewDelegate, BCMicroLocationManagerDelegate, LBSettingsViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MutableOrderedDictionary *sitesForSiteState;
@property (nonatomic, strong) BCMicroLocationManager *microLocationManager;
@property (nonatomic, strong) UIImageView *emptyImageView;

@end

@implementation LBNearbySitesViewController

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

- (MutableOrderedDictionary *)sitesForSiteState
{
    if (!_sitesForSiteState) {
        
        _sitesForSiteState = [[MutableOrderedDictionary alloc] init];
        [_sitesForSiteState setObject:[NSMutableArray array]
                               forKey:[self stringForSiteState:BCSiteStateInside]];
        [_sitesForSiteState setObject:[NSMutableArray array]
                               forKey:[self stringForSiteState:BCSiteStateOutside]];
        [_sitesForSiteState setObject:[NSMutableArray array]
                               forKey:[self stringForSiteState:BCSiteStateUnknown]];
    }
    return _sitesForSiteState;
}

- (BCMicroLocationManager *)microLocationManager
{
    if (!_microLocationManager) {
        _microLocationManager = [BCMicroLocationManager sharedManager];
    }
    return _microLocationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.view addSubview:self.tableView];
    
    self.navigationItem.title = @"Nearby Sites";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showSettings:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshNearbySites)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *appToken = [FXKeychain defaultKeychain][LBKeychainKeyAppToken];
    if (![appToken isGuid]) {
        [self showSettingsAnimated:NO];
    }
    else {
        
        self.microLocationManager.delegate = self;
        
        //[self showEmptyViewIfNeeded];
        
        [self requestStateForNearbySites];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    _microLocationManager = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (NSUInteger)numberOfSitesInLookup
{
    NSUInteger count = 0;
    for (NSInteger index = 0 ; index < self.sitesForSiteState.count; index++) {
        count += [self sitesForSection:index].count;
    }
    return count;
}

- (void)showEmptyViewIfNeeded
{
    if ([self numberOfSitesInLookup] <= 0) {
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

- (void)refreshNearbySites
{
    _sitesForSiteState = nil;
    
    [self.tableView reloadData];
    
    //[self showEmptyViewIfNeeded];
    
    [self requestStateForNearbySites];
}

- (void)requestStateForNearbySites
{
    NSOrderedSet *nearbySites = self.microLocationManager.nearbySites;
    
    for (BCSite *site in nearbySites) {
        [self.microLocationManager requestStateForSite:site];
    }
}

- (void)showSettings:(id)sender
{
    [self showSettingsAnimated:YES];
}

- (void)showSettingsAnimated:(BOOL)animated
{
    LBSettingsViewController *viewController = [[LBSettingsViewController alloc] init];
    viewController.delegate = self;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]
                       animated:animated
                     completion:nil];
}

- (NSArray *)sitesForSection:(NSInteger)section
{
    return [self.sitesForSiteState objectAtIndex:section];
}

- (BCSite *)siteAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sites = [self sitesForSection:indexPath.section];
    return [sites objectAtIndex:indexPath.row];
}

- (NSString *)keyForSection:(NSInteger)section
{
    return [self.sitesForSiteState keyAtIndex:section];
}

- (void)determinedState:(BCSiteState)state forSite:(BCSite *)site
{
    NSMutableArray *sites = [self.sitesForSiteState objectForKey:[self stringForSiteState:state]];
    if (![sites containsObject:site]) {
        
        BOOL removed = NO;
        if (state != BCSiteStateInside && !removed) {
            removed = [self removeSite:site fromArrayForSiteState:BCSiteStateInside];
        }
        
        if (state != BCSiteStateOutside && !removed) {
            removed = [self removeSite:site fromArrayForSiteState:BCSiteStateOutside];
        }
        
        if (state != BCSiteStateUnknown && !removed) {
            removed = [self removeSite:site fromArrayForSiteState:BCSiteStateUnknown];
        }
        
        [sites addObject:site];
        
        [self.tableView reloadData];
        
        //[self showEmptyViewIfNeeded];
    }
}

- (BOOL)removeSite:(BCSite *)site fromArrayForSiteState:(BCSiteState)state
{
    NSMutableArray *sites = [self.sitesForSiteState objectForKey:[self stringForSiteState:state]];
    if ([sites containsObject:site]) {
        [sites removeObject:site];
        return YES;
    }
    return NO;
}

- (NSString *)stringForSiteState:(BCSiteState)state
{
    switch (state) {
        case BCSiteStateInside:
            return @"Inside";
        case BCSiteStateOutside:
            return @"Outside";
        default:
            return @"Unknown";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sitesForSiteState.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sites = [self sitesForSection:section];
    return sites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BCSite *site = [self siteAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLBSiteCellIdentifier];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:kLBSiteCellIdentifier];
        cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = site.name;
    NSString *format = [NSString stringWithFormat:@"%%d beacon%@", site.beaconCount == 1 ? @"" : @"s"];
    cell.detailTextLabel.text = [NSString stringWithFormat:format, site.beaconCount];
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self keyForSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBSiteDetailViewController *viewController = [[LBSiteDetailViewController alloc] init];
    viewController.site = [self siteAtIndexPath:indexPath];

    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Micro-location manager delegate

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didUpdateNearbySites:(NSArray *)sites
{
    [self refreshNearbySites];
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didEnterSite:(BCSite *)site
{
    [self determinedState:BCSiteStateInside forSite:site];
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didExitSite:(BCSite *)site
{
    [self determinedState:BCSiteStateOutside forSite:site];
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didDetermineState:(BCSiteState)state forSite:(BCSite *)site
{
    [self determinedState:state forSite:site];
}

#pragma mark - LBCategoriesViewControllerDelegate methods

- (void)settingsViewControllerDone:(LBSettingsViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)settingsViewController:(LBSettingsViewController *)viewController didSaveAppToken:(NSString *)appToken
{
    [BlueCatsSDK setAppToken:appToken];
    [self.microLocationManager startUpdatingMicroLocation];
}

@end
