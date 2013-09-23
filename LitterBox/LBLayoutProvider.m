//
//  LBLayoutProvider.m
//  LitterBox
//
//  Created by Cody Singleton on 9/23/13.
//  Copyright (c) 2013 BlueCats. All rights reserved.
//

#import "LBLayoutProvider.h"

// site name label constants
const CGFloat kSiteNameLabelHeight_Phone = 65.0f;
const CGFloat kSiteNameLabelXOffset_Phone = 70.0f;
const CGFloat kSiteNameLabelYOffset_Phone = 10.0f;

const CGFloat kSiteNameLabelHeight_Pad = 129.0f;
const CGFloat kSiteNameLabelXOffset_Pad = 134.0f;
const CGFloat kSiteNameLabelYOffset_Pad = 10.0f;

// site greeting label constants
const CGFloat kSiteGreetingLabelHeight_Phone = 50.0f;
const CGFloat kSiteGreetingLabelXOffset_Phone = 70.0f;
const CGFloat kSiteGreetingLabelYOffset_Phone = 92.0f;

const CGFloat kSiteGreetingLabelHeight_Pad = 100.0f;
const CGFloat kSiteGreetingLabelXOffset_Pad = 140.0f;
const CGFloat kSiteGreetingLabelYOffset_Pad = 185.0f;

// categories label constants
const CGFloat kCategoriesLabelWidth_Phone = 300.0f;
const CGFloat kCategoriesLabelHeight_Phone = 210.0f;
const CGFloat kCategoriesLabelYOffset_Phone = 275.0f;

const CGFloat kCategoriesLabelWidth_Pad = 748.0f;
const CGFloat kCategoriesLabelHeight_Pad = 345.0f;
const CGFloat kCategoriesLabelYOffset_Pad = 530.0f;

@implementation LBLayoutProvider

+ (CGRect)siteNameLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kSiteNameLabelHeight_Pad;
        labelFrame.origin.y = hidden ? -(kSiteNameLabelHeight_Pad + kSiteNameLabelYOffset_Pad) : kSiteNameLabelYOffset_Pad;
        labelFrame.origin.x = kSiteNameLabelXOffset_Pad;
        labelFrame.size.width = labelFrame.size.width - kSiteNameLabelXOffset_Pad;
    }
    else {
        labelFrame.size.height = kSiteNameLabelHeight_Phone;
        labelFrame.origin.y = hidden ? -(kSiteNameLabelHeight_Phone + kSiteNameLabelYOffset_Phone) : kSiteNameLabelYOffset_Phone;
        labelFrame.origin.x = kSiteNameLabelXOffset_Phone;
        labelFrame.size.width = labelFrame.size.width - kSiteNameLabelXOffset_Phone;
    }
    return labelFrame;
}

+ (UIFont *)siteNameLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:64.0f];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:32.0f];
    }
}

+ (CGRect)siteGreetingLabelFrameForBounds:(CGRect)bounds hidden:(BOOL)hidden
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kSiteGreetingLabelHeight_Pad;
        labelFrame.origin.y = kSiteGreetingLabelYOffset_Pad;
        labelFrame.size.width = labelFrame.size.width - kSiteGreetingLabelXOffset_Pad;
        labelFrame.origin.x = hidden ? bounds.size.width : kSiteGreetingLabelXOffset_Pad;
    }
    else {
        labelFrame.size.height = kSiteGreetingLabelHeight_Phone;
        labelFrame.origin.y = kSiteGreetingLabelYOffset_Phone;
        labelFrame.size.width = labelFrame.size.width - kSiteGreetingLabelXOffset_Phone;
        labelFrame.origin.x = hidden ? bounds.size.width : kSiteGreetingLabelXOffset_Phone;
    }
    return labelFrame;
}

+ (UIFont *)siteGreetingLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:28.0f];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    }
}

+ (CGRect)categoriesLabelFrameForBounds:(CGRect)bounds
{
    CGRect labelFrame = bounds;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        labelFrame.size.height = kCategoriesLabelHeight_Pad;
        labelFrame.origin.y = kCategoriesLabelYOffset_Pad;
        labelFrame.size.width = kCategoriesLabelWidth_Pad;
        labelFrame.origin.x = (bounds.size.width - kCategoriesLabelWidth_Pad) / 2.0;
    }
    else {
        labelFrame.size.height = kCategoriesLabelHeight_Phone;
        labelFrame.origin.y = kCategoriesLabelYOffset_Phone;
        labelFrame.size.width = kCategoriesLabelWidth_Phone;
        labelFrame.origin.x = (bounds.size.width - kCategoriesLabelWidth_Phone) / 2.0;
    }
    return labelFrame;
}

+ (UIFont *)categoryLabelFont
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:(arc4random() % 72 + 32)];
    }
    else {
        return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:(arc4random() % 36 + 16)];
    }
}

@end
