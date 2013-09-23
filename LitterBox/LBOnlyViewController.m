//
//  LBOnlyViewController.m
//  LitterBox
//
//  Created by Cody Singleton on 9/19/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBOnlyViewController.h"
#import "BCMicroLocationManager.h"
#import "BCMicroLocation.h"
#import "BCSite.h"
#import "BCCategory.h"

const CGFloat kSiteNameLabelHeight = 65.0f;
const CGFloat kSiteNameLabelXOffset = 70.0f;
const CGFloat kSiteNameLabelYOffset = 10.0f;

const CGFloat kSiteGreetingLabelHeight = 50.0f;
const CGFloat kSiteGreetingLabelXOffset = 70.0f;
const CGFloat kSiteGreetingLabelYOffset = 92.0f;

const CGFloat kCategoriesLabelWidth = 300.0f;
const CGFloat kCategoriesLabelHeight = 210.0f;
const CGFloat kCategoriesLabelYOffset = 275.0f;

@interface LBOnlyViewController ()

@property (nonatomic, strong) UILabel *siteNameLabel;
@property (nonatomic, assign) BOOL siteNameLabelIsVisible;

@property (nonatomic, strong) UILabel *siteGreetingLabel;
@property (nonatomic, assign) BOOL siteGreetingLabelIsVisible;

@property (nonatomic, strong) UILabel *categoriesLabel;
@property (nonatomic, assign) BOOL categoriesLabelIsVisible;

@end

@implementation LBOnlyViewController

- (UILabel *)siteNameLabel
{
    if (!_siteNameLabel) {
        
        CGRect labelFrame = self.view.bounds;
        labelFrame.size.height = kSiteNameLabelHeight;
        labelFrame.origin.y = -kSiteNameLabelHeight;
        labelFrame.origin.x = kSiteNameLabelXOffset;
        labelFrame.size.width = labelFrame.size.width - kSiteNameLabelXOffset;
        _siteNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0f];
        _siteNameLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:106.0f/255.0f blue:173.0f/255.0f alpha:1.0f];
        _siteNameLabel.textAlignment = NSTextAlignmentCenter;
        _siteNameLabel.backgroundColor = [UIColor clearColor];
    }
    return _siteNameLabel;
}

- (UILabel *)siteGreetingLabel
{
    if (!_siteGreetingLabel) {
        
        CGRect labelFrame = self.view.bounds;
        labelFrame.size.height = kSiteGreetingLabelHeight;
        labelFrame.origin.y = kSiteGreetingLabelYOffset;
        labelFrame.size.width = labelFrame.size.width - kSiteGreetingLabelXOffset;
        labelFrame.origin.x = self.view.bounds.size.width;
        _siteGreetingLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteGreetingLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14.0f];
        _siteGreetingLabel.textColor = [UIColor whiteColor];
        _siteGreetingLabel.textAlignment = NSTextAlignmentLeft;
        _siteGreetingLabel.backgroundColor = [UIColor clearColor];
        _siteGreetingLabel.numberOfLines = 0;
    }
    return _siteGreetingLabel;
}

- (UILabel *)categoriesLabel
{
    if (!_categoriesLabel) {
        
        CGRect labelFrame = self.view.bounds;;
        labelFrame.size.height = kCategoriesLabelHeight;
        labelFrame.origin.y = kCategoriesLabelYOffset;
        labelFrame.size.width = kCategoriesLabelWidth;
        labelFrame.origin.x = (self.view.bounds.size.width - kCategoriesLabelWidth) / 2.0;
        _categoriesLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _categoriesLabel.textColor = [UIColor whiteColor];
        _categoriesLabel.textAlignment = NSTextAlignmentCenter;
        _categoriesLabel.backgroundColor = [UIColor clearColor];
        _categoriesLabel.numberOfLines = 0;
    }
    return _categoriesLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[self backgroundImageName]]];
    
    self.siteNameLabelIsVisible = NO;
    self.siteGreetingLabelIsVisible = NO;
    self.categoriesLabelIsVisible = NO;
    
    [self.view addSubview:self.siteNameLabel];
    [self.view addSubview:self.siteGreetingLabel];
    [self.view addSubview:self.categoriesLabel];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(microLocationManagerDidEnterSiteNotification:)
                                                 name:BCMicroLocationManagerDidEnterSite
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(microLocationManagerDidExitSiteNotification:)
                                                 name:BCMicroLocationManagerDidExitSite
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(microLocationManagerDidUpdateMicroLocationNotification:)
                                                 name:BCMicroLocationManagerDidUpdateMicroLocation
                                               object:nil];
}

- (NSString *)backgroundImageName
{
    NSString *imageName = @"bg";
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (screenRect.size.height == 568.0f)
        imageName = [imageName stringByAppendingString:@"-568h.png"];
    
    return imageName;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BCMicroLocation *microLocation = [BCMicroLocationManager sharedManager].microLocation;
    if (microLocation) {
        [self animateDidEnterSite:microLocation.site];
    }
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

- (void)animateDidEnterSite:(BCSite *)site
{
    [UIView animateWithDuration:1.25f animations:^{
        
        if (site) {
            self.siteNameLabel.text = site.name.uppercaseString;
        }
        else {
            self.siteNameLabel.text = nil;
        }
        
        self.siteNameLabel.frame = CGRectOffset(self.siteNameLabel.frame, 0, (self.siteNameLabel.frame.size.height + kSiteNameLabelYOffset));
        self.siteNameLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
    
    [UIView animateWithDuration:0.75f animations:^{
        
        if (site) {
            self.siteGreetingLabel.text = site.greeting;
        }
        else {
            self.siteGreetingLabel.text = nil;
        }
        
        self.siteGreetingLabel.frame = CGRectOffset(self.siteGreetingLabel.frame, -(self.view.bounds.size.width - kSiteGreetingLabelXOffset), 0.0f);
        self.siteGreetingLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (void)animateDidExitSite:(BCSite *)site
{
    [UIView animateWithDuration:1.25f animations:^{
        self.siteNameLabel.frame = CGRectOffset(self.siteNameLabel.frame, 0, -(self.siteNameLabel.frame.size.height + kSiteNameLabelYOffset));
        self.siteNameLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.siteNameLabel.text = nil;
        }
    }];
    
    [UIView animateWithDuration:0.75f animations:^{
        self.siteGreetingLabel.frame = CGRectOffset(self.siteGreetingLabel.frame, (self.view.bounds.size.width - kSiteGreetingLabelXOffset), 0.0f);
        self.siteGreetingLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.siteGreetingLabel.text = nil;
        }
    }];
}

- (NSAttributedString *)attributedStringForCategories:(NSArray *)categories
{
    if (!categories || categories.count <= 0)
        return nil;
    
    NSArray *categoryNames = [categories valueForKeyPath:@"name"];
    NSString *joinedCategoryNames = [categoryNames componentsJoinedByString:@"\r"];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:joinedCategoryNames];
    
    NSUInteger startIndex = 0;
    for (BCCategory *category in categories) {
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:(arc4random() % 36 + 16)] range:NSMakeRange(startIndex, category.name.length)];
        startIndex += category.name.length + 1;
    }
    
    return attributedString;
}

#pragma mark - MicroLocationManager Notifications

- (void)microLocationManagerDidEnterSiteNotification:(NSNotification *)notification
{
    BCSite *site = [notification.userInfo objectForKey:BCMicroLocationManagerNotificationSiteItem];
    [self animateDidEnterSite:site];
}

- (void)microLocationManagerDidExitSiteNotification:(NSNotification *)notification
{
    BCSite *site = [notification.userInfo objectForKey:BCMicroLocationManagerNotificationSiteItem];
    [self animateDidExitSite:site];
}

- (void)microLocationManagerDidUpdateMicroLocationNotification:(NSNotification *)notification
{
    BCMicroLocation *microLocation = [notification.userInfo objectForKey:BCMicroLocationManagerNotificationNewLocationItem];
    
    NSAttributedString *attributedString = [self attributedStringForCategories:microLocation.categories];
    
    [UIView animateWithDuration:1.75f animations:^{
        if (attributedString) self.categoriesLabel.attributedText = attributedString;
        self.categoriesLabel.alpha = attributedString ? 1.0f : 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            if (!attributedString) self.categoriesLabel.text = nil;
        }
    }];
}

@end
