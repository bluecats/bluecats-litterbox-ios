//
//  LBMicroLocationViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 9/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBMicroLocationViewController.h"
#import "BCMicroLocationManager.h"
#import "BCMicroLocation.h"
#import "BCSite.h"
#import "BCCategory.h"
#import "BCBeacon.h"
#import "LBLayoutProvider.h"
#import "LBCategoriesViewController.h"

@interface LBMicroLocationViewController () <LBCategoriesViewControllerDelegate, BCMicroLocationManagerDelegate>

@property (nonatomic, strong) BCMicroLocationManager *microLocationManager;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UISegmentedControl *proximitySegmentedControl;
@property (nonatomic, strong) UIImageView *siteImageView;
@property (nonatomic, strong) UILabel *siteNameLabel;
@property (nonatomic, strong) UILabel *siteStateLabel;
@property (nonatomic, strong) UILabel *valuesLabel;
@property (nonatomic, strong) UISegmentedControl *keySegmentedControl;

- (BCProximity)selectedProximity;

@end

@implementation LBMicroLocationViewController

@synthesize site = _site;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.shadowImageView = [self findShadowImageViewUnder:self.navigationController.navigationBar];
   
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"All Categories"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showAllCategories:)];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageName]]];
    
    [self.view addSubview:self.proximitySegmentedControl];
    [self.view addSubview:self.siteImageView];
    [self.view addSubview:self.siteNameLabel];
    [self.view addSubview:self.siteStateLabel];
    [self.view addSubview:self.keySegmentedControl];
    [self.view addSubview:self.valuesLabel];
}

- (NSString *)backgroundImageName
{
    NSString *imageName = @"bg";
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (screenRect.size.height == 568.0f)
        imageName = [imageName stringByAppendingString:@"-568h.png"];
    
    return imageName;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.shadowImageView.hidden = YES;
    self.microLocationManager.delegate = self;
    [self.microLocationManager requestStateForSite:self.site];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateDidEnterSite:self.site];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.microLocationManager.delegate = nil;
    _microLocationManager = nil;
    self.shadowImageView.hidden = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Private methods

- (UIImageView *)findShadowImageViewUnder:(UIView *)view {
    
    if ([view isKindOfClass:[UIImageView class]]) {
        CGSize size = view.bounds.size;
        if (size.width == 320.0f && size.height == 0.5f) {
            return (UIImageView *)view;
        }
    }
    
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findShadowImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    
    return nil;
}

- (void)showAllCategories:(id)sender
{
    LBCategoriesViewController *viewController = [[LBCategoriesViewController alloc] init];
    viewController.delegate = self;
    viewController.site = self.site;
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:viewController]
                       animated:YES
                     completion:nil];
}

- (void)animateDidEnterSite:(BCSite *)site
{
    __weak LBMicroLocationViewController *weakSelf = self;
    
    [UIView animateWithDuration:0.75f animations:^{
        
        weakSelf.siteNameLabel.text = site ? site.name : nil;
        weakSelf.siteNameLabel.alpha = 1.0f;
        weakSelf.siteNameLabel.frame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds
                                                                              hidden:NO];
        
        weakSelf.siteStateLabel.alpha = 1.0f;
        weakSelf.siteStateLabel.frame = [LBLayoutProvider siteStateLabelFrameForBounds:self.view.bounds
                                                                                hidden:NO];
    } completion:nil];
    
    [UIView animateWithDuration:1.25f animations:^{
        
        weakSelf.siteImageView.alpha = 1.0f;
        weakSelf.siteImageView.frame = [LBLayoutProvider siteImageViewFrameForBounds:self.view.bounds
                                                                           imageSize:self.siteImageView.image.size
                                                                              hidden:NO];
    } completion:nil];
    
    [UIView animateWithDuration:2.0f animations:^{
        
         weakSelf.keySegmentedControl.alpha = 1.0f;
    } completion:nil];
}

- (void)animateDidExitSite:(BCSite *)site
{
    __weak LBMicroLocationViewController *weakSelf = self;
    [UIView animateWithDuration:1.25f animations:^{
        
        weakSelf.siteImageView.alpha = 0.0f;
        weakSelf.siteImageView.frame = [LBLayoutProvider siteImageViewFrameForBounds:self.view.bounds
                                                                           imageSize:self.siteImageView.image.size
                                                                              hidden:YES];
    } completion:nil];
    
    [UIView animateWithDuration:0.75f animations:^{
        
        weakSelf.siteNameLabel.alpha = 0.0f;
        weakSelf.siteNameLabel.frame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds
                                                                              hidden:YES];
        
        weakSelf.siteStateLabel.alpha = 0.0f;
        weakSelf.siteStateLabel.frame = [LBLayoutProvider siteStateLabelFrameForBounds:self.view.bounds
                                                                                hidden:YES];
    } completion:nil];
    
    [UIView animateWithDuration:1.0f animations:^{
        
        weakSelf.keySegmentedControl.alpha = 0.0f;
    } completion:nil];
}

- (void)setValuesForMicroLocation:(BCMicroLocation *)microLocation
{
    NSAttributedString *attributedString =nil;
    if (microLocation) {
        
        if (self.keySegmentedControl.selectedSegmentIndex == 0) {
            NSArray *categories = [microLocation categoriesForSite:self.site proximity:self.selectedProximity];
            NSArray *categoryNames = [categories valueForKeyPath:@"name"];
            attributedString = [self attributedStringForValues:categoryNames];
        }
        else {
            NSArray *beacons = [microLocation beaconsForSite:self.site proximity:self.selectedProximity];
            
            //NOTE: In previous version of LitterBox beacon.compositeKey was displayed here.
            //In later releases this property has been renamed to beacon.iBeaconKey
            //The iBeaconKey property is only relevant when beacons are broadcasting in iBeaconMode
            //so serial number which is a unique identifier for a beacon in all modes is now
            //used instead
            NSMutableArray *beaconSerialNumbers = [[NSMutableArray alloc] init];
            for (BCBeacon *beacon in beacons) {
                [beaconSerialNumbers addObject:beacon.serialNumber];
            }
            
            attributedString = [self attributedStringForValues:beaconSerialNumbers];
        }
    }
    
    __weak LBMicroLocationViewController *weakSelf = self;
    [UIView animateWithDuration:0.75f animations:^{
        
        if (attributedString) {
        
            weakSelf.valuesLabel.attributedText = attributedString;
            weakSelf.valuesLabel.alpha = 1.0f;
        }
        else {
            
            weakSelf.valuesLabel.alpha = 0.0f;
        }
        
        
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (!attributedString) {
                weakSelf.valuesLabel.text = nil;
            }
        }
    }];
}

- (NSAttributedString *)attributedStringForValues:(NSArray *)values
{
    if (!values || values.count <= 0)
        return nil;
    
    NSString *joinedCompositeKeys = [values componentsJoinedByString:@"\r"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:joinedCompositeKeys];
    
    NSUInteger startIndex = 0;
    for (NSString *value in values) {
        
        NSUInteger length = value.length;
        [attributedString addAttribute:NSFontAttributeName value:[LBLayoutProvider valuesLabelFont] range:NSMakeRange(startIndex, length)];
        startIndex += length + 1;
    }
    
    return attributedString;
}

- (void)setSiteStateLabelTextWithState:(BCSiteState)state
{
    if (state == BCSiteStateUnknown) {
        self.siteStateLabel.text = nil;
    }
    else {
        self.siteStateLabel.text = [self stringForSiteState:state].uppercaseString;
    }
}

- (BCProximity)selectedProximity
{
    BCProximity proximity = BCProximityUnknown;
    
    switch (self.proximitySegmentedControl.selectedSegmentIndex) {
        case 0:
            proximity = BCProximityImmediate;
            break;
        case 1:
            proximity = BCProximityNear;
            break;
        case 2:
            proximity = BCProximityFar;
            break;
        case 3:
        default:
            proximity = BCProximityUnknown;
            break;
    }
    return proximity;
}

- (void)proximitySegmentedControlChangedValue:(id)sender
{
    [self setValuesForMicroLocation:self.microLocationManager.microLocation];
}

- (void)keySegmentedControlChangedValue:(id)sender
{
    [self setValuesForMicroLocation:self.microLocationManager.microLocation];
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

#pragma mark - BCMicroLocationManagerDelegate methods

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didDetermineState:(BCSiteState)state forSite:(BCSite *)site
{
    if ([site.siteID isEqualToString:self.site.siteID]) {
        [self setSiteStateLabelTextWithState:state];
    }
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didEnterSite:(BCSite *)site
{
    if ([site.siteID isEqualToString:self.site.siteID]) {
        [self setSiteStateLabelTextWithState:BCSiteStateInside];
    }
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didExitSite:(BCSite *)site
{
    if ([site.siteID isEqualToString:self.site.siteID]) {
        [self setSiteStateLabelTextWithState:BCSiteStateOutside];
    }
}

- (void)microLocationManager:(BCMicroLocationManager *)microLocationManger didUpdateMicroLocations:(NSArray *)microLocations
{
    BCMicroLocation *microLocation = [microLocations lastObject];

    [self setValuesForMicroLocation:microLocation];
}

#pragma mark - LBCategoriesViewControllerDelegate methods

- (void)categoriesViewControllerDone:(LBCategoriesViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Property getter methods

- (BCMicroLocationManager *)microLocationManager
{
    if (!_microLocationManager) {
        
        _microLocationManager = [BCMicroLocationManager sharedManager];
    }
    return _microLocationManager;
}

- (UISegmentedControl *)proximitySegmentedControl
{
    if (!_proximitySegmentedControl) {
        
        _proximitySegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Immediate", @"Near", @"Far", @"Unknown"]];
        _proximitySegmentedControl.frame = CGRectMake(14.0f, 74.0f, self.view.frame.size.width - 28.0f, 28.0f);
        _proximitySegmentedControl.selectedSegmentIndex = 1;
        [_proximitySegmentedControl addTarget:self
                                       action:@selector(proximitySegmentedControlChangedValue:)
                             forControlEvents:UIControlEventValueChanged];
        
    }
    return _proximitySegmentedControl;
}

- (UISegmentedControl *)keySegmentedControl
{
    if (!_keySegmentedControl) {
        
        CGRect segmentedControlFrame = [LBLayoutProvider keySegmenetedControlFrameForBounds:self.view.bounds];
        _keySegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Categories", @"Beacons"]];
        _keySegmentedControl.frame = segmentedControlFrame;
        _keySegmentedControl.selectedSegmentIndex = 0;
        _keySegmentedControl.tintColor = [UIColor whiteColor];
        _keySegmentedControl.alpha = 0.0f;
        [_keySegmentedControl addTarget:self
                                 action:@selector(keySegmentedControlChangedValue:)
                       forControlEvents:UIControlEventValueChanged];
        
    }
    return _keySegmentedControl;
}

- (UILabel *)valuesLabel
{
    if (!_valuesLabel) {
        
        CGRect labelFrame = [LBLayoutProvider valuesLabelFrameForBounds:self.view.bounds];
        _valuesLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _valuesLabel.textColor = [UIColor whiteColor];
        _valuesLabel.textAlignment = NSTextAlignmentCenter;
        _valuesLabel.backgroundColor = [UIColor clearColor];
        _valuesLabel.alpha = 0.0f;
        _valuesLabel.numberOfLines = 0;
    }
    return _valuesLabel;
}

- (UILabel *)siteNameLabel
{
    if (!_siteNameLabel) {
        
        CGRect labelFrame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds hidden:YES];
        _siteNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteNameLabel.font = [LBLayoutProvider siteNameLabelFont];
        _siteNameLabel.textColor = [UIColor whiteColor];
        _siteNameLabel.textAlignment = NSTextAlignmentLeft;
        _siteNameLabel.backgroundColor = [UIColor clearColor];
        _siteNameLabel.alpha = 0.0f;
    }
    return _siteNameLabel;
}

- (UILabel *)siteStateLabel
{
    if (!_siteStateLabel) {
        
        CGRect labelFrame = [LBLayoutProvider siteStateLabelFrameForBounds:self.view.bounds hidden:YES];
        _siteStateLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteStateLabel.font = [LBLayoutProvider siteStateLabelFont];
        _siteStateLabel.textColor = [UIColor whiteColor];
        _siteStateLabel.textAlignment = NSTextAlignmentLeft;
        _siteStateLabel.backgroundColor = [UIColor clearColor];
        _siteStateLabel.alpha = 0.0f;
    }
    return _siteStateLabel;
}

- (UIImageView *)siteImageView
{
    if (!_siteImageView) {
        
        _siteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"site-icon-white"]];
        _siteImageView.alpha = 0.0f;
        CGRect imageViewframe = [LBLayoutProvider siteImageViewFrameForBounds:self.view.bounds
                                                                    imageSize:_siteImageView.image.size
                                                                       hidden:YES];
        _siteImageView.frame = imageViewframe;
    }
    return _siteImageView;
}

@end
