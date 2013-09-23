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
#import "LBLayoutProvider.h"

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
        CGRect labelFrame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds hidden:YES];
        _siteNameLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteNameLabel.font = [LBLayoutProvider siteNameLabelFont];
        _siteNameLabel.textColor = [UIColor colorWithRed:0.0f/255.0f green:106.0f/255.0f blue:173.0f/255.0f alpha:1.0f];
        _siteNameLabel.textAlignment = NSTextAlignmentCenter;
        _siteNameLabel.backgroundColor = [UIColor clearColor];
    }
    return _siteNameLabel;
}

- (UILabel *)siteGreetingLabel
{
    if (!_siteGreetingLabel) {
        CGRect labelFrame = [LBLayoutProvider siteGreetingLabelFrameForBounds:self.view.bounds hidden:YES];
        _siteGreetingLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _siteGreetingLabel.font = [LBLayoutProvider siteGreetingLabelFont];
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
        CGRect labelFrame = [LBLayoutProvider categoriesLabelFrameForBounds:self.view.bounds];
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
        
        self.siteNameLabel.text = site ? site.name.uppercaseString : nil;
        
        self.siteNameLabel.frame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds hidden:NO];
        self.siteNameLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
    
    [UIView animateWithDuration:0.75f animations:^{
        
        self.siteGreetingLabel.text = site ? site.greeting : nil;
        
        self.siteGreetingLabel.frame = [LBLayoutProvider siteGreetingLabelFrameForBounds:self.view.bounds hidden:NO];
        self.siteGreetingLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

- (void)animateDidExitSite:(BCSite *)site
{
    [UIView animateWithDuration:1.25f animations:^{
        self.siteNameLabel.frame = [LBLayoutProvider siteNameLabelFrameForBounds:self.view.bounds hidden:YES];
        self.siteNameLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.siteNameLabel.text = nil;
        }
    }];
    
    [UIView animateWithDuration:0.75f animations:^{
        self.siteGreetingLabel.frame = [LBLayoutProvider siteGreetingLabelFrameForBounds:self.view.bounds hidden:YES];
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
        [attributedString addAttribute:NSFontAttributeName value:[LBLayoutProvider categoryLabelFont] range:NSMakeRange(startIndex, category.name.length)];
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
